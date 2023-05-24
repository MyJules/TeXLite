
#include "latex.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>

class TexGuard {
public:
    TexGuard() {
        tex::LaTeX::init();
    }

    ~TexGuard() {
        tex::LaTeX::release();
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    TexGuard texGuard;

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/TeXLite/qml/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
