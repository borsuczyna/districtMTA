var path = @"C:\Program Files (x86)\MTA San Andreas 1.63\server\mods\deathmatch\resources\[serwer]";

var resourceManager = new ResourceManager(path);
resourceManager.CompileResources().Wait();