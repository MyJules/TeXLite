
#ifndef FILESYSTEM_H
#define FILESYSTEM_H

#include <QObject>
#include <QString>
#include <QQuickItem>

class FileSystem : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    FileSystem(QObject *parent = nullptr);
    Q_INVOKABLE QString readFile(const QString& filePath);
    Q_INVOKABLE void writeToFile(const QString& filePath, const QString& content);
};

#endif // FILESYSTEM_H
