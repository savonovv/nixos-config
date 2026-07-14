import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "black"

    property int sessionIndex: sessionModel.lastIndex

    Image {
        anchors.fill: parent
        source: "wallpaper.png"
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: lockIcon
        anchors.centerIn: parent
        text: "\uf023"
        color: "#dcd7ba"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 72
        style: Text.Outline
        styleColor: "#16161d"
    }

    TextInput {
        id: password
        anchors.centerIn: parent
        width: 1
        height: 1
        opacity: 0
        focus: true
        echoMode: TextInput.Password
        inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText

        Keys.onReturnPressed: submit()
        Keys.onEnterPressed: submit()

        function submit() {
            if (text.length > 0)
                sddm.login("gorilla", text, root.sessionIndex)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: password.forceActiveFocus()
    }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            successAnimation.start()
        }

        function onLoginFailed() {
            password.text = ""
            lockIcon.color = "#e82424"
            failureReset.restart()
            password.forceActiveFocus()
        }
    }

    Timer {
        id: failureReset
        interval: 700
        onTriggered: lockIcon.color = "#dcd7ba"
    }

    ParallelAnimation {
        id: successAnimation

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 450
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: lockIcon
            property: "scale"
            to: 0.7
            duration: 450
            easing.type: Easing.InCubic
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
