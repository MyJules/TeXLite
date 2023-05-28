
#include "texengine.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/qqmlregistration.h>
#include <QFile>

int main(int argc, char *argv[])
{
    QFile tempFile("temp.tex");
    tempFile.open(QIODevice::WriteOnly);
    QTextStream tempFileStream(&tempFile);

    tempFileStream << "\\documentclass{article} \n \n"
                   << "\\title{Hello TeXLite} \n"
                   << "\\author{Best User}"
                   << "\\date{\\today} \n"
                   << "\\begin{document} \n \n"
                   << "\\maketitle \n"
                   << "\\end{document}";

//'\\documentclass{article}

//\\title{Hello TeXLite}
//    \\author{Best User}
//    \\date{\\today}

//    \\begin{document}

//    \\maketitle

//\\end{document}'

    tempFile.close();

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
