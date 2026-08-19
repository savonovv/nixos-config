{ lib, pkgs, ... }:

let
  queueNumber = 200;
  mark = "0x40000000";
  luaDir = "${pkgs.zapret2}/share/zapret2/lua";

  strategyArgs = [
    "--qnum=${toString queueNumber}"
    "--user=nobody"
    "--lua-init=@${luaDir}/zapret-lib.lua"
    "--lua-init=@${luaDir}/zapret-antidpi.lua"
    "--filter-tcp=80"
    "--filter-l7=http"
    "--out-range=-d10"
    "--payload=http_req"
    "--lua-desync=fake:blob=fake_default_http:tcp_md5"
    "--lua-desync=multisplit:pos=method+2"
    "--new"
    "--filter-tcp=443"
    "--filter-l7=tls"
    "--out-range=-d10"
    "--payload=tls_client_hello"
    "--lua-desync=fake:blob=fake_default_tls:tcp_md5:tcp_seq=-10000"
    "--lua-desync=multidisorder:pos=1,midsld"
    "--new"
    "--filter-udp=443"
    "--filter-l7=quic"
    "--payload=quic_initial"
    "--lua-desync=fake:blob=fake_default_quic:repeats=6"
  ];

  setupFirewall = pkgs.writeShellScript "zapret2-setup-firewall" ''
    set -eu

    ${pkgs.nftables}/bin/nft delete table inet zapret2 2>/dev/null || true
    ${pkgs.nftables}/bin/nft -f - <<'EOF'
    table inet zapret2 {
      chain postrouting {
        type filter hook postrouting priority 101; policy accept;
        meta mark & ${mark} == 0 tcp dport { 80, 443 } ct original packets 1-20 queue num ${toString queueNumber} bypass
        meta mark & ${mark} == 0 udp dport 443 ct original packets 1-5 queue num ${toString queueNumber} bypass
      }

      chain prerouting {
        type filter hook prerouting priority -101; policy accept;
        meta mark & ${mark} == 0 tcp sport { 80, 443 } ct reply packets 1-10 queue num ${toString queueNumber} bypass
        meta mark & ${mark} == 0 udp sport 443 ct reply packets 1-3 queue num ${toString queueNumber} bypass
      }

      chain predefrag {
        type filter hook output priority -401; policy accept;
        meta mark & ${mark} != 0 notrack
      }
    }
    EOF

    ${pkgs.procps}/bin/sysctl -q -w net.netfilter.nf_conntrack_tcp_be_liberal=1
  '';

  cleanupFirewall = pkgs.writeShellScript "zapret2-cleanup-firewall" ''
    ${pkgs.nftables}/bin/nft delete table inet zapret2 2>/dev/null || true
  '';
in
{
  boot.kernelModules = [
    "nfnetlink_queue"
    "nft_queue"
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "zapret2.service" &&
          subject.user == "gorilla") {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.zapret2 = {
    description = "Zapret2 DPI desynchronization";
    documentation = [ "https://github.com/bol-van/zapret2" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "firewall.service"
      "network-online.target"
    ];

    serviceConfig = {
      Type = "simple";
      ExecStartPre = setupFirewall;
      ExecStart = lib.escapeShellArgs ([ "${pkgs.zapret2}/bin/nfqws2" ] ++ strategyArgs);
      ExecStopPost = cleanupFirewall;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
