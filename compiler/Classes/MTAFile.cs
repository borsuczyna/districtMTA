public class MTAFile
{
    public string path { get; set; }
    public string name { get; set; }
    public bool isValid { get; set; }

    public MTAFile(string path)
    {
        this.path = path;
        name = new DirectoryInfo(path).Name;
        isValid = true;
    }
}