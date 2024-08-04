using System.Xml;

public class MTAResource
{
    public string path { get; set; }
    public string name { get; set; }
    public string outputName { get; set; }
    public bool isValid { get; set; }
    private List<MTAScript> scripts { get; set; } = new();
    private List<MTAFile> files { get; set; } = new();

    public MTAResource(string path)
    {
        this.path = path;
        name = new DirectoryInfo(path).Name;
        outputName = name;

        if (Defines.compileResourceNames)
            outputName = StringEncoder.ReverselessEncode(outputName, 64);

        outputName = $"{Defines.resourceNameFooter}{outputName}";
        
        // Read resource
        isValid = ReadMeta();
    }

    private bool ReadMeta()
    {
        var metaPath = Path.Combine(path, "meta.xml");
        if (!File.Exists(metaPath))
            return false;
        
        var xml = new XmlDocument();
        xml.Load(metaPath);

        // Read scripts
        var scriptNodes = xml.SelectNodes("//script");
        if (scriptNodes == null)
        {
            Console.WriteLine($"Script nodes not found in {name}/meta.xml");
            return false;
        }
        
        foreach (XmlNode scriptNode in scriptNodes)
        {
            string? scriptPath = null;
            var scriptType = ScriptType.Shared;
            var attributes = scriptNode.Attributes;
            if (attributes != null)
            {
                var srcAttribute = attributes.GetNamedItem("src");
                if (srcAttribute != null)
                    scriptPath = srcAttribute.InnerText.Replace("/", "\\");

                var typeAttribute = attributes.GetNamedItem("type");
                if (typeAttribute != null)
                {
                    var type = typeAttribute.InnerText.ToLower();
                    scriptType = type switch
                    {
                        "server" => ScriptType.Server,
                        "client" => ScriptType.Client,
                        _ => ScriptType.Shared
                    };
                }
            }

            if (scriptPath == null)
            {
                Console.WriteLine($"Script path not found in {name}/meta.xml");
                return false;
            }

            var script = new MTAScript(scriptPath, scriptType);
            scripts.Add(script);
        }

        // Read files
        var fileNodes = xml.SelectNodes("//file");
        if (fileNodes == null)
        {
            Console.WriteLine($"File nodes not found in {name}/meta.xml");
            return false;
        }

        foreach (XmlNode fileNode in fileNodes)
        {
            string? filePath = null;
            var attributes = fileNode.Attributes;
            if (attributes != null)
            {
                var srcAttribute = attributes.GetNamedItem("src");
                if (srcAttribute != null)
                    filePath = srcAttribute.InnerText.Replace("/", "\\");
            }

            if (filePath == null)
            {
                Console.WriteLine($"File path not found in {name}/meta.xml");
                return false;
            }

            var file = new MTAFile(filePath);
            files.Add(file);
        }
        
        // read map
        var mapNodes = xml.SelectNodes("//map");
        if (mapNodes == null)
            return true;

        foreach (XmlNode mapNode in mapNodes)
        {
            string? filePath = null;
            var attributes = mapNode.Attributes;
            if (attributes != null)
            {
                var srcAttribute = attributes.GetNamedItem("src");
                if (srcAttribute != null)
                    filePath = srcAttribute.InnerText.Replace("/", "\\");
            }

            if (filePath == null)
            {
                Console.WriteLine($"Map path not found in {name}/meta.xml");
                return false;
            }

            var file = new MTAFile(filePath);
            files.Add(file);
        }

        return true;
    }

    private async Task<bool> CompileScript(MTAScript script, string outputPath)
    {
        var scriptPath = Path.Combine(outputPath, outputName, script.path);
        
        if (!Directory.Exists(scriptPath))
            Directory.CreateDirectory(scriptPath);

        scriptPath = Path.Combine(scriptPath, script.outputName);
        var buffer = await script.Compile(path);
        
        if (buffer == null)
        {
            Console.WriteLine($"Failed to compile {script.name}");
            return false;
        }

        await File.WriteAllBytesAsync(scriptPath, buffer);
        return true;
    }

    private void CopyMeta(string outputPath)
    {
        var metaPath = Path.Combine(path, "meta.xml");
        var outputMetaPath = Path.Combine(outputPath, outputName, "meta.xml");
        var xml = new XmlDocument();
        xml.Load(metaPath);

        if (Defines.compileScriptNames)
        {
            var scriptNodes = xml.SelectNodes("//script");
            if (scriptNodes != null)
            {
                foreach (XmlNode scriptNode in scriptNodes)
                {
                    var attributes = scriptNode.Attributes;
                    if (attributes == null)
                        continue;

                    var srcAttribute = attributes.GetNamedItem("src");
                    if (srcAttribute == null)
                        continue;

                    var newPath = Path.GetDirectoryName(srcAttribute.InnerText) ?? string.Empty;
                    var encodedName = StringEncoder.ReverselessEncode(Path.GetFileName(srcAttribute.InnerText), 64);
                    srcAttribute.InnerText = Path.Combine(newPath, encodedName);

                    var cacheAttribute = attributes.GetNamedItem("cache");
                    if (cacheAttribute == null)
                    {
                        var cache = xml.CreateAttribute("cache");
                        cache.Value = "false";
                        attributes.Append(cache);
                    }
                }
            }
        }

        var includeNodes = xml.SelectNodes("//include");
        if (includeNodes != null)
        {
            foreach (XmlNode includeNode in includeNodes)
            {
                var attributes = includeNode.Attributes;
                if (attributes == null)
                    continue;

                var resourceAttribute = attributes.GetNamedItem("resource");
                if (resourceAttribute == null)
                    continue;

                string newName = resourceAttribute.InnerText;
                if (Defines.compileResourceNames)
                    newName = StringEncoder.ReverselessEncode(newName, 64);
                
                var encodedName = $"{Defines.resourceNameFooter}{newName}";
                resourceAttribute.InnerText = encodedName;
            }
        }

        var minVersion = xml.SelectSingleNode("//min_mta_version");
        if (minVersion == null)
        {
            var minMtaVersion = xml.CreateElement("min_mta_version");
            var server = xml.CreateAttribute("server");
            server.Value = "1.6.0-9.20752";
            var client = xml.CreateAttribute("client");
            client.Value = "1.6.0-9.20752";
            minMtaVersion.Attributes.Append(server);
            minMtaVersion.Attributes.Append(client);
            xml.DocumentElement?.AppendChild(minMtaVersion);
        }

        xml.Save(outputMetaPath);
    }

    private void CopyFiles(string sourcePath, string outputPath)
    {
        foreach (var file in files)
        {
            var sourceFilePath = Path.Combine(sourcePath, file.path);
            var outputFilePath = Path.Combine(outputPath, outputName, file.path);

            if (!Directory.Exists(Path.GetDirectoryName(outputFilePath)))
                Directory.CreateDirectory(Path.GetDirectoryName(outputFilePath) ?? string.Empty);
            
            string extension = Path.GetExtension(file.name);
            switch (extension)
            {
                case ".html":
                    var html = File.ReadAllText(sourceFilePath);
                    var obfuscator = new HtmlObfuscator();
                    File.WriteAllText(outputFilePath, obfuscator.Obfuscate(html));
                    break;
                case ".js":
                    var js = File.ReadAllText(sourceFilePath);
                    var obfuscatedCode = JavaScriptObfuscator.Obfuscate(js);
                    if (obfuscatedCode == null)
                        throw new Exception("Failed to obfuscate JavaScript code");

                    File.WriteAllText(outputFilePath, obfuscatedCode);
                    break;
                case ".css":
                    var css = File.ReadAllText(sourceFilePath);
                    var minifiedCss = CSSMinifier.Minify(css);
                    File.WriteAllText(outputFilePath, minifiedCss);
                    break;
                default:
                    File.Copy(sourceFilePath, outputFilePath, true);
                    break;
            }
        }
    }

    public async Task<bool> CompileScripts(string outputPath)
    {
        var tasks = new List<Task<bool>>();
        List<bool> results = new();

        foreach (var script in scripts)
        {
            tasks.Add(CompileScript(script, outputPath));

            if (tasks.Count >= 5)
            {
                results.AddRange(await Task.WhenAll(tasks));
                tasks.Clear();
            }
        }

        results.AddRange(await Task.WhenAll(tasks));
        return results.All(x => x);
    }

    public async Task<bool> Compile(string outputPath)
    {
        var metaPath = Path.Combine(outputPath, outputName, "meta.xml");
        if (!Directory.Exists(Path.Combine(outputPath, outputName)))
            Directory.CreateDirectory(Path.Combine(outputPath, outputName));

        // File.Copy(Path.Combine(path, "meta.xml"), metaPath, true);
        CopyMeta(outputPath);

        CopyFiles(path, outputPath);
        return await CompileScripts(outputPath);
    }
}