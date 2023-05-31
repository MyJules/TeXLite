
#include "filesystem.h"

FileSystem::FileSystem(QObject *parent)
{

}

Q_INVOKABLE QString FileSystem::readFile(const QString &filePath)
{
    return "aaa";
}

Q_INVOKABLE void FileSystem::writeToFile(const QString &filePath, const QString &content)
{

}

Q_INVOKABLE void FileSystem::removeFile(const QString &filePath)
{

}

