#include <texengine.h>
#include <filesystem.h>
#include <tempfolderguard.h>
#include <syntaxhighlihgter.h>
#include <textcharformat.h>

#include <QIcon>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/qqmlregistration.h>

int main(int argc, char *argv[])
{
    TempFolderGuard tempfolder(QDir::currentPath(), "temp");

    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArray("Material"));

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/icons/imgs/icon.png"));

    qmlRegisterType<TexEngine>("com.tex", 1, 0, "TexEngine");
    qmlRegisterType<FileSystem>("com.file", 1, 0, "FileSystem");
    qmlRegisterType<SyntaxHighlighter>("com.highliter", 1, 0, "SyntaxHighlighter");
    qmlRegisterType<TextCharFormat>("com.highliter", 1, 0, "TextCharFormat");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/TeXLite/qml/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
