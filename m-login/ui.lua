function loadInterfaceFromFile(name, path)
    local file = fileOpen(path)
    local code = fileRead(file, fileGetSize(file))
    fileClose(file)
    
    exports['m-ui']:loadInterfaceElementFromCode(name, code)
end