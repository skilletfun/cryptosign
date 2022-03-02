from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtGui import QGuiApplication, QIcon
from PyQt5.QtCore import QObject, pyqtSlot
import sys
import random
import rsa


class Generator(QObject):
    def __init__(self):
        super(Generator, self).__init__()


    @pyqtSlot(result=str)
    def generateKey(self):
        alpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
        return ''.join([random.choice(alpha) for _ in range(64)])


    @pyqtSlot(result=list)
    def generatePair(self):
        (pub_key, priv_key) = rsa.newkeys(512)
        pub_key = str(pub_key)[10:-1]
        priv_key = str(priv_key)[11:-1]
        return [pub_key, priv_key]


    @pyqtSlot(str, str, result=str)
    def encrypt(self, msg, key):
        try:
            t_key = key
            n, e = [int(el) for el in t_key.split(', ')]
            t_key = rsa.PublicKey(n, e)
            return rsa.encrypt(msg.encode('utf8'), t_key).hex()

        except:
            key = (key * (len(msg) // len(key) + 1))[:len(msg)]
            res = ''

            for i in range(len(msg)):
                res += chr(ord(msg[i]) + ord(key[i]))
            return bytes(res, 'utf8').hex()


    @pyqtSlot(str, str, result=str)
    def decrypt(self, msg, key):
        try:
            t_key = key
            n, e, d, p, q = [int(el) for el in t_key.split(', ')]
            t_key = rsa.PrivateKey(n, e, d, p, q)
            return rsa.decrypt(bytes.fromhex(msg), t_key).decode('utf8')

        except:
            msg = bytes.fromhex(msg).decode('utf8')
            key = (key * (len(msg) // len(key) + 1))[:len(msg)]
            res = ''

            for i in range(len(msg)):
                res += chr(ord(msg[i]) - ord(key[i]))
            return res


if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    g = Generator()

    ctx = engine.rootContext()
    ctx.setContextProperty('generator', g)

    engine.load('main.qml')

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
