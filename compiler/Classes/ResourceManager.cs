using System.Reflection.Metadata;

public class ResourceManager
{
    private string path;
    private string outputPath;

    public List<MTAResource> resources { get; set; } = new();

    public ResourceManager(string path, string outputPath = "[output]")
    {
        this.path = path;
        this.outputPath = outputPath;

        CreateOutputPath();
        LoadResources(path);
    }

    private void CreateOutputPath()
    {
        if (!Directory.Exists(outputPath))
            Directory.CreateDirectory(outputPath);

        foreach (var file in Directory.GetFiles(outputPath))
            File.Delete(file);

        foreach (var directory in Directory.GetDirectories(outputPath))
            Directory.Delete(directory, true);
    }

    private void LoadResource(string path)
    {
        var resource = new MTAResource(path);
        if (resource.isValid)
            resources.Add(resource);
    }

    private void LoadResources(string path)
    {
        var directories = Directory.GetDirectories(path);
        foreach (var directoryPath in directories)
        {
            var directory = new DirectoryInfo(directoryPath).Name;

            if (directory.StartsWith("[") && directory.EndsWith("]"))
                LoadResources(directoryPath);
            else
                LoadResource(directoryPath);
        }
    }

    private async Task CompileResource(MTAResource resource, List<MTAResource> failed)
    {
        bool success = await resource.Compile(outputPath);
        if (success)
        {
            Console.WriteLine($"Compiled resource {resource.name}");
        }
        else
        {
            Console.WriteLine($"Failed to compile resource {resource.name}");
            failed.Add(resource);
        }
    }

    public async Task CompileResources()
    {
        List<MTAResource> failed = new();
        List<Task> tasks = new();

        foreach (var resource in resources)
        {
            tasks.Add(CompileResource(resource, failed));

            if (tasks.Count >= 5)
            {
                await Task.WhenAll(tasks);
                tasks.Clear();
            }
        }

        await Task.WhenAll(tasks);

        Console.WriteLine();
        Console.WriteLine($"Failed to compile {failed.Count} resources");
    }
}