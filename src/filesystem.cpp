
#include "filesystem.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>
#include <QTextStream>

namespace {
QString toLocalPath(const QString &path)
{
    const QString localPath = QUrl(path).toLocalFile();
    return localPath.isEmpty() ? path : localPath;
}

bool copyDirectoryRecursively(const QString &sourcePath, const QString &targetPath, QString *error)
{
    QDir sourceDir(sourcePath);
    if (!sourceDir.exists()) {
        if (error)
            *error = QString("Example project source '%1' does not exist.").arg(sourcePath);
        return false;
    }

    QDir targetDir;
    if (!targetDir.mkpath(targetPath)) {
        if (error)
            *error = QString("Could not create directory '%1'.").arg(targetPath);
        return false;
    }

    const QFileInfoList entries = sourceDir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
    for (const QFileInfo &entry : entries) {
        const QString sourceEntryPath = entry.filePath();
        const QString targetEntryPath = QDir(targetPath).filePath(entry.fileName());

        if (entry.isDir()) {
            if (!copyDirectoryRecursively(sourceEntryPath, targetEntryPath, error))
                return false;
            continue;
        }

        if (QFile::exists(targetEntryPath) && !QFile::remove(targetEntryPath)) {
            if (error)
                *error = QString("Could not replace file '%1'.").arg(targetEntryPath);
            return false;
        }

        if (!QFile::copy(sourceEntryPath, targetEntryPath)) {
            if (error)
                *error = QString("Could not copy '%1' to '%2'.").arg(sourceEntryPath, targetEntryPath);
            return false;
        }

        QFile targetFile(targetEntryPath);
        const QFileDevice::Permissions writablePermissions = targetFile.permissions()
                | QFileDevice::ReadOwner
                | QFileDevice::WriteOwner
                | QFileDevice::ReadUser
                | QFileDevice::WriteUser;
        if (!targetFile.setPermissions(writablePermissions)) {
            if (error)
                *error = QString("Could not make file '%1' writable.").arg(targetEntryPath);
            return false;
        }
    }

    return true;
}
}

FileSystem::FileSystem(QObject *parent)
{

}

Q_INVOKABLE QString FileSystem::readFile(const QString &filePath)
{
    QString path = toLocalPath(filePath);

    QFile file(path);
    if (!file.open(QFile::ReadOnly | QFile::Text))
        return "No file found";

    QTextStream in(&file);
    return in.readAll();
}

Q_INVOKABLE void FileSystem::writeToFile(const QString &filePath, const QString &content)
{
    const QString path = toLocalPath(filePath);
    setLastError("");

    const QFileInfo fileInfo(path);
    QDir parentDir = fileInfo.dir();
    if (!parentDir.exists() && !parentDir.mkpath(".")) {
        setLastError(QString("Could not create directory '%1'.").arg(parentDir.path()));
        return;
    }

    QSaveFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        setLastError(QString("Could not open file '%1' for writing: %2")
                     .arg(path, file.errorString()));
        return;
    }

    QTextStream out(&file);
    out << content;
    out.flush();

    if (!file.commit()) {
        setLastError(QString("Could not save file '%1': %2")
                     .arg(path, file.errorString()));
        return;
    }
}

Q_INVOKABLE void FileSystem::removeFile(const QString &filePath)
{
    QString path = toLocalPath(filePath);
    QFile file(path);
}

Q_INVOKABLE void FileSystem::newFile(const QString &filePath)
{
    QString path = toLocalPath(filePath);

    setLastError("");

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        setLastError(QString("Could not create file '%1'.").arg(path));
        return;
    }

    file.close();
    qDebug() << path;
}

Q_INVOKABLE void FileSystem::clearTempFolder()
{
    QDir tempDir(QDir::currentPath() + "/temp");
    tempDir.removeRecursively();
    tempDir.mkdir(QDir::currentPath() + "/temp");
}

Q_INVOKABLE QString FileSystem::getFileDir(const QString &filePath)
{
    QFileInfo info(toLocalPath(filePath));
    return QUrl::fromLocalFile(info.dir().path()).toString();
}

Q_INVOKABLE void FileSystem::copyFile(const QString &from, const QString &to)
{
    const QString sourcePath = toLocalPath(from);
    const QString targetPath = toLocalPath(to);

    if (QFile::exists(targetPath))
    {
        QFile::remove(targetPath);
    }

    QFile::copy(sourcePath, targetPath);
}

Q_INVOKABLE QString FileSystem::createExampleProject(const QString &exampleId, const QString &targetDir)
{
    setLastError("");

    const QString targetPath = toLocalPath(targetDir);
    QString sourcePath;

    if (exampleId == "article") {
        sourcePath = ":/examples/article";
    } else if (exampleId == "report") {
        sourcePath = ":/examples/report";
    } else if (exampleId == "beamer") {
        sourcePath = ":/examples/beamer";
    } else {
        setLastError(QString("Unknown example project '%1'.").arg(exampleId));
        return "";
    }

    QString error;
    if (!copyDirectoryRecursively(sourcePath, targetPath, &error)) {
        setLastError(error);
        return "";
    }

    return QUrl::fromLocalFile(QDir(targetPath).filePath("main.tex")).toString();
}

QString FileSystem::lastError() const
{
    return m_lastError;
}

void FileSystem::setLastError(const QString &error)
{
    if (m_lastError == error)
        return;

    m_lastError = error;
    emit lastErrorChanged();
}
