
#ifndef TEMPFOLDERGUARD_H
#define TEMPFOLDERGUARD_H

#include <QDir>
#include <QString>

class TempFolderGuard
{
public:
    TempFolderGuard(const QString& folderPath, const QString& folderName);
    ~TempFolderGuard();

private:
    QDir m_folder;
};

#endif // TEMPFOLDERGUARD_H
