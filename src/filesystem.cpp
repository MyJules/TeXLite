
#include "filesystem.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QSaveFile>
#include <QTextStream>
#include <QUrl>

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
    : QObject(parent)
    , m_fileWatcher(new QFileSystemWatcher(this))
    , m_ignoreNextWatchedChange(false)
{
    connect(m_fileWatcher, &QFileSystemWatcher::fileChanged,
            this, &FileSystem::onWatchedFileChanged);
    connect(m_fileWatcher, &QFileSystemWatcher::directoryChanged,
            this, &FileSystem::onWatchedDirectoryChanged);
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

    if (path == m_watchedFilePath)
        watchFile(path);
}

Q_INVOKABLE void FileSystem::removeFile(const QString &filePath)
{
    removePath(filePath);
}

Q_INVOKABLE void FileSystem::removePath(const QString &filePath)
{
    const QString path = toLocalPath(filePath);
    setLastError("");

    if (path.isEmpty()) {
        setLastError("No path provided.");
        return;
    }

    QFileInfo entryInfo(path);
    if (!entryInfo.exists()) {
        setLastError(QString("Path '%1' does not exist.").arg(path));
        return;
    }

    bool removed = false;
    if (entryInfo.isDir())
        removed = QDir(path).removeRecursively();
    else
        removed = QFile::remove(path);

    if (!removed) {
        setLastError(QString("Could not delete '%1'.").arg(path));
        return;
    }

    if (!m_watchedFilePath.isEmpty()
            && (m_watchedFilePath == path
                || m_watchedFilePath.startsWith(path + QDir::separator()))) {
        watchFile("");
    }
}

Q_INVOKABLE void FileSystem::newFile(const QString &filePath)
{
    const QString path = toLocalPath(filePath);

    setLastError("");

    const QFileInfo fileInfo(path);
    QDir parentDir = fileInfo.dir();
    if (!parentDir.exists() && !parentDir.mkpath(".")) {
        setLastError(QString("Could not create directory '%1'.").arg(parentDir.path()));
        return;
    }

    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        setLastError(QString("Could not create file '%1'.").arg(path));
        return;
    }

    file.close();
}

Q_INVOKABLE void FileSystem::newFolder(const QString &folderPath)
{
    const QString path = toLocalPath(folderPath);

    setLastError("");

    if (path.isEmpty()) {
        setLastError("No folder path provided.");
        return;
    }

    QDir dir;
    if (!dir.mkpath(path))
        setLastError(QString("Could not create folder '%1'.").arg(path));
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

Q_INVOKABLE QString FileSystem::normalizeFilePath(const QString &filePath)
{
    const QString localPath = toLocalPath(filePath);
    if (localPath.isEmpty())
        return "";

    const QFileInfo fileInfo(localPath);
    const QString canonicalPath = fileInfo.canonicalFilePath();
    return canonicalPath.isEmpty() ? QDir::cleanPath(localPath) : canonicalPath;
}

Q_INVOKABLE QString FileSystem::resolveRelativeFilePath(const QString &baseFilePath,
                                                        const QString &relativePath)
{
    const QString localBasePath = toLocalPath(baseFilePath);
    QString localRelativePath = toLocalPath(relativePath);

    if (localBasePath.isEmpty() || localRelativePath.isEmpty())
        return "";

    QFileInfo relativeInfo(localRelativePath);
    QString resolvedPath = relativeInfo.isAbsolute()
            ? localRelativePath
            : QFileInfo(localBasePath).dir().filePath(localRelativePath);

    if (QFileInfo(resolvedPath).suffix().isEmpty())
        resolvedPath += ".tex";

    return normalizeFilePath(resolvedPath);
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

Q_INVOKABLE void FileSystem::watchFile(const QString &filePath)
{
    const QString path = toLocalPath(filePath);

    if (!m_watchedFilePath.isEmpty()) {
        m_fileWatcher->removePath(m_watchedFilePath);
        m_watchedFilePath.clear();
    }

    if (!m_watchedDirectoryPath.isEmpty()) {
        m_fileWatcher->removePath(m_watchedDirectoryPath);
        m_watchedDirectoryPath.clear();
    }

    m_watchedFileLastModified = QDateTime();

    if (path.isEmpty())
        return;

    m_watchedFilePath = path;
    m_watchedDirectoryPath = QFileInfo(path).dir().path();

    if (!m_watchedDirectoryPath.isEmpty())
        m_fileWatcher->addPath(m_watchedDirectoryPath);

    refreshWatchedFileState(false);
}

QString FileSystem::lastError() const
{
    return m_lastError;
}

void FileSystem::onWatchedFileChanged(const QString &path)
{
    Q_UNUSED(path)
    refreshWatchedFileState(true);
}

void FileSystem::onWatchedDirectoryChanged(const QString &path)
{
    Q_UNUSED(path)
    refreshWatchedFileState(true);
}

void FileSystem::refreshWatchedFileState(bool emitChange)
{
    if (m_watchedFilePath.isEmpty())
        return;

    const QFileInfo fileInfo(m_watchedFilePath);

    if (!m_watchedDirectoryPath.isEmpty()
            && !m_fileWatcher->directories().contains(m_watchedDirectoryPath)) {
        m_fileWatcher->addPath(m_watchedDirectoryPath);
    }

    if (!fileInfo.exists())
        return;

    if (!m_fileWatcher->files().contains(m_watchedFilePath))
        m_fileWatcher->addPath(m_watchedFilePath);

    const QDateTime lastModified = fileInfo.lastModified();
    const bool changed = m_watchedFileLastModified.isValid()
            && lastModified.isValid()
            && lastModified != m_watchedFileLastModified;

    m_watchedFileLastModified = lastModified;

    if (!emitChange || !changed)
        return;

    if (m_ignoreNextWatchedChange) {
        m_ignoreNextWatchedChange = false;
        return;
    }

    emit watchedFileChanged(QUrl::fromLocalFile(m_watchedFilePath).toString());
}

void FileSystem::setLastError(const QString &error)
{
    if (m_lastError == error)
        return;

    m_lastError = error;
    emit lastErrorChanged();
}
