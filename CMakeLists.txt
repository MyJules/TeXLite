cmake_minimum_required(VERSION 3.16)

project(TeXLite VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTORCC ON)

set (CMAKE_CXX_STANDARD 17)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Concurrent)

include_directories(src)

qt_standard_project_setup()

qt_add_executable(appTeXLite
    src/main.cpp
    src/texengine.cpp
    src/tempfolderguard.cpp
    src/filesystem.cpp
    src/syntaxhighlihgter.cpp
    src/textcharformat.cpp
    resource.qrc
)

qt_add_qml_module(appTeXLite
    URI TeXLite
    VERSION 1.0
    QML_FILES
    qml/Main.qml
    qml/AppMenuBar.qml
    qml/AppFooter.qml
    qml/LatexTextEdit.qml
    qml/PDFView.qml
    qml/TexEngines.qml
    qml/BusyPDFIndicator.qml
    qml/DirView.qml
    qml/CompilationErrorView.qml
    qml/IntellisenseMenu.qml
    qml/LatexListModel.qml
    qml/LatexTextEditWithIntellisense.qml
)

set_target_properties(appTeXLite PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTeXLite
    PRIVATE
    Qt6::Quick
    Qt6::Concurrent
)

install(TARGETS appTeXLite
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
