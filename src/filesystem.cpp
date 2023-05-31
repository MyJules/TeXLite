
#include "filesystem.h"

#include <QFile>

FileSystem::FileSystem(QObject *parent)
{

}

Q_INVOKABLE QString FileSystem::readFile(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();

    QFile file(path);
    if (!file.open(QFile::ReadOnly | QFile::Text))
        return "No file found";

    QTextStream in(&file);
    return in.readAll();

}

Q_INVOKABLE void FileSystem::writeToFile(const QString &filePath, const QString &content)
{
    QString path = QUrl(filePath).toLocalFile();

    QFile file(path);
    if (file.open(QIODevice::ReadWrite | QFile::Truncate)) {
        QTextStream out(&file);
        out << content;
    }
}

Q_INVOKABLE void FileSystem::removeFile(const QString &filePath)
{

}

Q_INVOKABLE void FileSystem::newFile(const QString &filePath)
{
    QString path = QUrl(filePath).toLocalFile();

    if (QFile::exists(path)) return;

    QFile file(path);
    file.open(QIODevice::WriteOnly);
    file.close();
}
