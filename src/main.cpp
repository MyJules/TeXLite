
#include <texengine.h>
#include <filesystem.h>
#include <tempfolderguard.h>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/qqmlregistration.h>

int main(int argc, char *argv[])
{
    TempFolderGuard tempfolder(QDir::currentPath(), "temp");

    QGuiApplication app(argc, argv);

    qmlRegisterType<TexEngine>("com.tex", 1, 0, "TexEngine");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/TeXLite/qml/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
