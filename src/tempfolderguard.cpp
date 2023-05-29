
#include "tempfolderguard.h"

TempFolderGuard::TempFolderGuard(const QString& folderPath, const QString& folderName)
    : m_folder(folderPath)
{
    m_folder.mkdir(folderName);
    m_folder.cd(folderName);
}

TempFolderGuard::~TempFolderGuard()
{
    m_folder.removeRecursively();
}
