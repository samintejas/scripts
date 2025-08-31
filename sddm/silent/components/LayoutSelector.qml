import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: selector
    width: (Config.layoutPopupWidth - Config.menuAreaPopupsPadding * 2) * Config.generalScale

    signal layoutChanged(layoutIndex: int)
    signal close

    property int currentLayoutIndex: (keyboard && keyboard.layouts && keyboard.layouts.length > 0) ? keyboard.currentLayout : 0
    property string layoutName: ""
    property string layoutShortName: ""

    function updateLayout() {
        if (keyboard && keyboard.layouts && selector.currentLayoutIndex >= 0 && selector.currentLayoutIndex < keyboard.layouts.length) {
            keyboard.currentLayout = selector.currentLayoutIndex;
            selector.layoutName = keyboard.layouts[selector.currentLayoutIndex].longName;
            selector.layoutShortName = keyboard.layouts[selector.currentLayoutIndex].shortName;
        }
        selector.layoutChanged(selector.currentLayoutIndex);
    }

    Component.onCompleted: {
        selector.layoutName = keyboard && keyboard.layouts.length > 0 ? keyboard.layouts[selector.currentLayoutIndex].longName : "";
        selector.layoutShortName = keyboard && keyboard.layouts.length > 0 ? keyboard.layouts[selector.currentLayoutIndex].shortName : "";
        selector.layoutChanged(selector.currentLayoutIndex);
    }

    Text {
        id: noLayoutMessage
        Layout.preferredWidth: parent.width - 5
        text: "No keyboard layout could be found. This is a known issue with Wayland."
        visible: keyboard == undefined || keyboard.layouts.length === 0
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        color: Config.menuAreaPopupsContentColor
        font.pixelSize: Config.menuAreaPopupsFontSize * Config.generalScale
        font.family: Config.menuAreaPopupsFontFamily
        padding: 10
    }

    ListView {
        id: layoutList
        visible: !noLayoutMessage.visible
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: Math.min((keyboard && keyboard.layouts ? keyboard.layouts.length : 0) * ((Config.menuAreaPopupsItemHeight * Config.generalScale) + 5 + spacing) - spacing, Config.menuAreaPopupsMaxHeight * Config.generalScale)
        orientation: ListView.Vertical
        interactive: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: Config.menuAreaPopupsSpacing
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0

        contentHeight: (keyboard && keyboard.layouts ? keyboard.layouts.length : 0) * ((Config.menuAreaPopupsItemHeight * Config.generalScale) + 5 + spacing) - spacing

        ScrollBar.vertical: ScrollBar {
            id: scrollbar
            policy: Config.menuAreaPopupsDisplayScrollbar && layoutList.contentHeight > layoutList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            contentItem: Rectangle {
                implicitWidth: 5 * Config.generalScale
                radius: 5 * Config.generalScale
                color: Config.menuAreaPopupsContentColor
                opacity: Config.menuAreaPopupsActiveOptionBackgroundOpacity
            }
        }

        model: keyboard && keyboard.layouts ? keyboard.layouts : []

        delegate: Rectangle {
            width: scrollbar.visible ? selector.width - Config.menuAreaPopupsPadding - scrollbar.width : selector.width
            height: childrenRect.height
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Config.menuAreaPopupsActiveOptionBackgroundColor
                opacity: index === currentLayoutIndex ? Config.menuAreaPopupsActiveOptionBackgroundOpacity : (mouseArea.containsMouse ? Config.menuAreaPopupsActiveOptionBackgroundOpacity : 0.0)
                radius: 5
            }

            RowLayout {
                width: parent.width
                height: (Config.menuAreaPopupsItemHeight * Config.generalScale) + 5
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: Layout.preferredHeight
                    color: "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: shortName && shortName.length > 0 ? `/usr/share/sddm/flags/${shortName}.png` : Config.getIcon("language")
                        width: Config.menuAreaPopupsIconSize * Config.generalScale
                        height: width
                        sourceSize: Qt.size(width, height)
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Column {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true

                    Text {
                        width: parent.width
                        text: Languages.getLabelFor(shortName)
                        visible: text && text.length > 0
                        color: index === currentLayoutIndex || mouseArea.containsMouse ? Config.menuAreaPopupsActiveContentColor : Config.menuAreaPopupsContentColor
                        font.pixelSize: Config.menuAreaPopupsFontSize * Config.generalScale
                        font.family: Config.menuAreaPopupsFontFamily
                        elide: Text.ElideRight
                        rightPadding: 10
                    }

                    Text {
                        width: parent.width
                        text: longName
                        color: index === currentLayoutIndex || mouseArea.containsMouse ? Config.menuAreaPopupsActiveContentColor : Config.menuAreaPopupsContentColor
                        opacity: 0.75
                        font.pixelSize: (Config.menuAreaPopupsFontSize * Config.generalScale) - 2
                        font.family: Config.menuAreaPopupsFontFamily
                        elide: Text.ElideRight
                        rightPadding: 10
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: index !== selector.currentLayoutIndex
                hoverEnabled: index !== selector.currentLayoutIndex
                z: 2
                cursorShape: hoverEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    selector.currentLayoutIndex = index;
                    selector.updateLayout();
                }
            }
        }
    }
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_Down) {
            if (keyboard && keyboard.layouts && keyboard.layouts.length > 0) {
                selector.currentLayoutIndex = (selector.currentLayoutIndex + keyboard.layouts.length + 1) % keyboard.layouts.length;
                selector.updateLayout();
            }
        } else if (event.key === Qt.Key_Up) {
            if (keyboard && keyboard.layouts && keyboard.layouts.length > 0) {
                selector.currentLayoutIndex = (selector.currentLayoutIndex + keyboard.layouts.length - 1) % keyboard.layouts.length;
                selector.updateLayout();
            }
        } else if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key === Qt.Key_Space) {
            selector.close();
        } else if (event.key === Qt.Key_CapsLock) {
            root.capsLockOn = !root.capsLockOn;
        }
    }
}
