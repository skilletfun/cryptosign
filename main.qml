import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

Window {
    id: root
    width: 900
    height: 600
    title: 'Crypto Sign'
    visible: true

    color: base_color

    property color base_color: '#1a1f23'
    property color light_color: '#2b8d8c'
    property color dark_color: '#2a2f35'
    property color hover_dark_color: '#282f35'
    property color hover_light_color: '#31a09f'
    property color press_dark_color: '#191c20'
    property color press_light_color: '#257979'

    property string current_sender: 'Alice'

    ListModel { id: chat }
    ListModel { id: alice_stars }
    ListModel { id: bob_stars }

    ListView {
        id: view
        anchors.fill: parent
        anchors.margins: 25
        anchors.bottomMargin: 100
        clip: true
        model: chat
        spacing: 10

        add: Transition {
            NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 300 }
        }

        addDisplaced: Transition {
            NumberAnimation { properties: "x"; duration: 300 }
        }

        populate: Transition {
            NumberAnimation { properties: "x"; duration: 300 }
        }

        delegate: Rectangle {
            width: 350
            height: visible ? message.contentHeight + 40 : 1
            opacity: current_sender == _own || _send ? 1 : 0
            visible: opacity == 0 ? false : true
            radius: 25

            color: _own == 'Alice' ? dark_color : light_color

            anchors.margins: _send ? 30 : 0

            Behavior on opacity { PropertyAnimation { duration: 300 } }
            Behavior on height { PropertyAnimation { duration: 300 } }
            Behavior on anchors.margins { PropertyAnimation { duration: 300 } }

            Button {
                id: send_mail
                height: 50
                visible: index == chat.count-1
                width: height
                anchors.right: _own == 'Alice' ? parent.right : parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: _own == 'Alice' ? -45 : 0
                background: Rectangle { color: 'transparent' }
                icon.source: 'mail.png'
                icon.color: 'transparent'
                padding: 0
                display: AbstractButton.IconOnly

                Behavior on opacity { PropertyAnimation { duration: 300 } }

                onReleased: {
                    opacity = 0;
                    chat.setProperty(index, '_send', true);
                    hide_btn_group();
                }
            }

            Text {
                id: message
                text: _text
                font.pointSize: 14
                color: 'white'
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 50
                wrapMode: Text.WrapAnywhere

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onReleased: { input.text = _text; hide_btn_group(); }
                }
            }

            Text {
                id: time
                text: _time
                color: 'white'
                font.pointSize: 11
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 10
            }

            Button {
                id: add_to_stars

                property bool added_by_Alice: false
                property bool added_by_Bob: false

                height: 30
                width: height
                anchors.right: _own == 'Alice' ? parent.right : parent.left
                anchors.top: parent.top
                anchors.topMargin: -5
                anchors.rightMargin: _own == 'Alice' ? -5 : -25
                background: Rectangle { color: 'transparent' }
                icon.source: 'star.png'
                icon.height: height
                icon.width: width
                icon.color: current_sender == 'Alice' && added_by_Alice || current_sender == 'Bob' && added_by_Bob ? 'transparent' : 'grey'
                padding: 0
                display: AbstractButton.IconOnly

                onReleased: {
                    label_field.visible = true;

                    hide_btn_group();
                }
            }

            TextField {
                id: label_field
                visible: false
                x: _own == 'Alice' ? 365 : -95
                y: -15
                height: 50
                width: 80
                background: Rectangle { color: 'transparent' }
                font.pointSize: 14
                placeholderText: 'Label'
                placeholderTextColor: 'grey'
                color: 'white'
                selectionColor: 'grey'
                maximumLength: 6

                onVisibleChanged: {
                    if (visible) focus = true;
                    text = '';
                }

                onReleased: { hide_btn_group(); }

                onAccepted: {
                    if (text != '')
                    {
                        if (current_sender == 'Alice')
                        {
                            alice_stars.append({ Key: text, Value: _text });
                            add_to_stars.added_by_Alice = true;
                        }
                        else
                        {
                            bob_stars.append({ Key: text, Value: _text });
                            add_to_stars.added_by_Bob = true;
                        }
                    }

                    focus = false;
                    visible = false;
                    hide_btn_group();
                }
            }

            Component.onCompleted: {
                if (_own === 'Bob') anchors.right = parent.right;
                else anchors.left = parent.left;
            }
        }
    }

    // For change States
    Button {
        id: change_to_Alice
        anchors.top: view.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.horizontalCenter
        background: Rectangle {color: 'transparent'}
        onReleased: {
            root.current_sender = 'Alice';
            hide_btn_group();
        }
    }

    // For change States
    Button {
        id: change_to_Bob
        anchors.top: view.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.horizontalCenter
        background: Rectangle { color: 'transparent' }
        onReleased: {
            root.current_sender = 'Bob';
            hide_btn_group();
        }
    }

    // Send messages etc
    Rectangle {
        id: sender_box
        height: 60
        width: parent.width/2.5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        radius: height/2
        color: current_sender == 'Alice' ? dark_color : light_color
        x: root.current_sender == 'Alice' ? 0.25*width : parent.width - 1.25*width

        Behavior on x { PropertyAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 300 } }

        Button {
            id: show
            height: parent.height - 20
            width: height
            anchors.left: parent.left
            background: Rectangle { id: show_bg; radius: show.height/2; color: 'transparent';
                Behavior on color { ColorAnimation { from: color; to: 'transparent'; duration: 300 } } }
            anchors.verticalCenter: input.verticalCenter
            anchors.leftMargin: 15
            icon.source: 'show.png'
            icon.color: 'transparent'
            padding: 0
            display: AbstractButton.IconOnly

            Behavior on opacity { PropertyAnimation { duration: 300 } }
            Behavior on rotation { PropertyAnimation { duration: 300 } }

            onReleased: {
                show_bg.color = 'grey';
                btn_group.opacity = Math.abs(btn_group.opacity-1);
                rotation = Math.abs(rotation-180);
            }
        }

        Rectangle {
            id: btn_group
            width: show.width + 20
            opacity: 0
            visible: opacity == 0 ? false: true
            height: show.height * 4 + btn_group_layout.spacing * 3 + 20
            anchors.bottom: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 5
            color: base_color
            radius: width / 2

            Behavior on opacity { PropertyAnimation { duration: 300 } }

            Column {
                id: btn_group_layout
                anchors.fill: parent
                anchors.margins: 10

                spacing: 5

                property int _height: show.height
                property int _width: show.width

                Button {
                    id: generate_one
                    height: parent._height
                    width: parent._width
                    background: Rectangle { radius: generate_one.height/2;
                        color: current_sender == 'Alice' ? generate_one.down ? press_dark_color : dark_color :
                                generate_one.down ? press_light_color : light_color }

                    Text {
                        text: 'K'
                        font.pointSize: 14
                        anchors.centerIn: parent
                        color: 'white'
                    }

                    onReleased: { hide_btn_group(); input.text = generator.generateKey(); }
                }

                Button {
                    id: generate_pair
                    height: parent._height
                    width: parent._width
                    background: Rectangle { radius: generate_pair.height/2;
                        color: current_sender == 'Alice' ? generate_pair.down ? press_dark_color : dark_color :
                                generate_pair.down ? press_light_color : light_color }

                    Text {
                        text: '2K'
                        font.pointSize: 14
                        anchors.centerIn: parent
                        color: 'white'
                    }

                    onReleased: {
                        var keys = generator.generatePair();
                        send_msg(keys[1]);
                        send_msg(keys[0]);
                    }
                }

                Button {
                    id: encrypt
                    height: parent._height
                    width: parent._width
                    background: Rectangle { radius: encrypt.height/2;
                        color: current_sender == 'Alice' ? encrypt.down ? press_dark_color : dark_color :
                                encrypt.down ? press_light_color : light_color }

                    Text {
                        text: 'E'
                        font.pointSize: 14
                        anchors.centerIn: parent
                        color: 'white'
                    }

                    onReleased: {
                        picker_popup.type_action = 'e';
                        picker_popup.open();
                    }
                }

                Button {
                    id: decrypt
                    height: parent._height
                    width: parent._width
                    background: Rectangle { radius: decrypt.height/2;
                        color: current_sender == 'Alice' ? decrypt.down ? press_dark_color : dark_color :
                                decrypt.down ? press_light_color : light_color }

                    Text {
                        text: 'D'
                        font.pointSize: 14
                        anchors.centerIn: parent
                        color: 'white'
                    }

                    onReleased: {
                        picker_popup.type_action = 'd';
                        picker_popup.open();
                    }
                }

                Popup {
                    id: picker_popup

                    x: parent.width + 20
                    y: -10
                    height: btn_group.height
                    width: 120
                    padding: 0

                    property string type_action: ''

                    background: Rectangle { radius: 20; color: base_color }

                    enter: Transition {
                        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
                    }

                    exit: Transition {
                        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
                    }

                    onClosed: { hide_btn_group(); }

                    ListView {
                        id: picker_view
                        anchors.fill: parent
                        anchors.margins: 10
                        model: current_sender == 'Alice' ? alice_stars : bob_stars
                        spacing: 5
                        clip: true

                        delegate: Button {
                            id: btn
                            height: 40
                            width: picker_view.width
                            background: Rectangle { radius: btn.height/2;  color: current_sender == 'Alice' ?
                                btn.down ? press_dark_color : dark_color : btn.down ? press_light_color : light_color }

                            Text {
                                text: Key
                                font.pointSize: 14
                                anchors.centerIn: parent
                                color: 'white'
                            }

                            onReleased: {
                                if (input.text != '')
                                {
                                    if (picker_popup.type_action == 'e')
                                    {
                                        var res = generator.encrypt(input.text, Value);
                                    }
                                    else
                                    {
                                        var res = generator.decrypt(input.text, Value);
                                    }
                                    send_msg(res);
                                }
                                hide_btn_group();
                                picker_popup.close();
                            }
                        }
                    }
                }
            }
        }


        TextField {
            id: input
            anchors.fill: parent
            anchors.margins: 10
            anchors.leftMargin: 60
            anchors.rightMargin: 60
            background: Rectangle { color: 'transparent' }
            font.pointSize: 14
            placeholderText: 'Write a message...'
            placeholderTextColor: 'white'
            color: 'white'
            selectionColor: 'grey'

            onAccepted: { focus = false; }
        }

        Button {
            id: send
            enabled: opacity == 1 ? true : false
            opacity: input.text == '' ? 0 : 1
            height: parent.height - 20
            width: height
            anchors.right: parent.right
            background: Rectangle { id: send_bg; radius: send.height/2; color: 'transparent';
                Behavior on color { ColorAnimation { from: color; to: 'transparent'; duration: 300 } } }
            anchors.verticalCenter: input.verticalCenter
            anchors.rightMargin: 15
            icon.source: 'send.png'
            icon.color: 'transparent'
            padding: 0
            display: AbstractButton.IconOnly

            Behavior on opacity { PropertyAnimation { duration: 300 } }

            onReleased: {
                send_msg(input.text);
            }
        }
    }

    function send_msg(msg)
    {
        var date = new Date();

        var sec = String(date.getSeconds());
        var min = String(date.getMinutes());

        if (sec.length === 1){ sec = '0' + sec; }
        if (min.length === 1){ min = '0' + min; }

        var time = String(date.getHours()) + ':' + min + ':' + sec;

        chat.append({_own: current_sender, _text: msg, _time: time, _send: false});
        send_bg.color = 'grey';
        input.text = '';

        view.currentIndex = view.count - 1;

        hide_btn_group();
    }

    function hide_btn_group()
    {
        btn_group.opacity = 0;
        show.rotation = 0;
    }
}
