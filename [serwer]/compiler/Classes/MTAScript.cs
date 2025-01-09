using System.Text;
using System.Text.RegularExpressions;

public enum ScriptType
{
    Server,
    Client,
    Shared
}

public class MTAScript
{
    private static HttpClient _httpClient = new();
    private Dictionary<string, bool> apiCodes = new()
    {
        ["ERROR Nothing to do - Please select compile and/or obfuscate"] = true,
        ["ERROR Could not compile file"] = true,
        ["ERROR Could not read file"] = true,
        ["ERROR Already compiled"] = true,
        ["ERROR Already encrypted"] = true,
    };

    private static List<string> ignoredEventNames = new() {
        "onAccountDataChange",
        "onAccountCreate",
        "onAccountRemove",
        "onConsole",
        "onColShapeHit",
        "onColShapeLeave",
        "onElementClicked",
        "onElementColShapeHit",
        "onElementColShapeLeave",
        "onElementDataChange",
        "onElementDestroy",
        "onElementDimensionChange",
        "onElementInteriorChange",
        "onElementModelChange",
        "onElementStartSync",
        "onElementStopSync",
        "onMarkerHit",
        "onMarkerLeave",
        "onPickupHit",
        "onPickupLeave",
        "onPickupSpawn",
        "onPickupUse",
        "onPlayerACInfo",
        "onPlayerBan",
        "onPlayerChangeNick",
        "onPlayerChat",
        "onPlayerClick",
        "onPlayerCommand",
        "onPlayerConnect",
        "onPlayerContact",
        "onPlayerDamage",
        "onPlayerDetonateSatchels",
        "onPlayerJoin",
        "onPlayerLogin",
        "onPlayerLogout",
        "onPlayerMarkerHit",
        "onPlayerMarkerLeave",
        "onPlayerModInfo",
        "onPlayerMute",
        "onPlayerNetworkStatus",
        "onPlayerPickupHit",
        "onPlayerPickupLeave",
        "onPlayerPickupUse",
        "onPlayerPrivateMessage",
        "onPlayerProjectileCreation",
        "onPlayerQuit",
        "onPlayerScreenShot",
        "onPlayerSpawn",
        "onPlayerStealthKill",
        "onPlayerTarget",
        "onPlayerTeamChange",
        "onPlayerTriggerEventThreshold",
        "onPlayerTriggerInvalidEvent",
        "onPlayerUnmute",
        "onPlayerVehicleEnter",
        "onPlayerVehicleExit",
        "onPlayerVoiceStart",
        "onPlayerVoiceStop",
        "onPlayerWasted",
        "onPlayerWeaponFire",
        "onPlayerWeaponSwitch",
        "onPedDamage",
        "onPedVehicleEnter",
        "onPedVehicleExit",
        "onPedWasted",
        "onPedWeaponSwitch",
        "onResourceStateChange",
        "onPlayerResourceStart",
        "onResourceLoadStateChange",
        "onResourcePreStart",
        "onResourceStart",
        "onResourceStop",
        "onBan",
        "onChatMessage",
        "onDebugMessage",
        "onExplosion",
        "onSettingChange",
        "onUnban",
        "onTrailerAttach",
        "onTrailerDetach",
        "onVehicleDamage",
        "onVehicleEnter",
        "onVehicleExit",
        "onVehicleExplode",
        "onVehicleRespawn",
        "onVehicleStartEnter",
        "onVehicleStartExit",
        "onWeaponFire",
        "onClientBrowserCreated",
        "onClientBrowserCursorChange",
        "onClientBrowserDocumentReady",
        "onClientBrowserInputFocusChanged",
        "onClientBrowserLoadingFailed",
        "onClientBrowserLoadingStart",
        "onClientBrowserNavigate",
        "onClientBrowserPopup",
        "onClientBrowserResourceBlocked",
        "onClientBrowserTooltip",
        "onClientBrowserWhitelistChange",
        "onClientColShapeHit",
        "onClientColShapeLeave",
        "onClientElementColShapeHit",
        "onClientElementColShapeLeave",
        "onClientElementDataChange",
        "onClientElementDestroy",
        "onClientElementDimensionChange",
        "onClientElementInteriorChange",
        "onClientElementModelChange",
        "onClientElementStreamIn",
        "onClientElementStreamOut",
        "onClientCharacter",
        "onClientClick",
        "onClientCursorMove",
        "onClientDoubleClick",
        "onClientKey",
        "onClientPaste",
        "onClientGUIAccepted",
        "onClientGUIBlur",
        "onClientGUIChanged",
        "onClientGUIClick",
        "onClientGUIComboBoxAccepted",
        "onClientGUIDoubleClick",
        "onClientGUIFocus",
        "onClientGUIMouseDown",
        "onClientGUIMouseUp",
        "onClientGUIMove",
        "onClientGUIScroll",
        "onClientGUISize",
        "onClientGUITabSwitched",
        "onClientMouseEnter",
        "onClientMouseLeave",
        "onClientMouseMove",
        "onClientMouseWheel",
        "onClientMarkerHit",
        "onClientMarkerLeave",
        "onClientPedDamage",
        "onClientPedHeliKilled",
        "onClientPedHitByWaterCannon",
        "onClientPedVehicleEnter",
        "onClientPedVehicleExit",
        "onClientPedWasted",
        "onClientPedWeaponFire",
        "onClientPedStep",
        "onClientPickupHit",
        "onClientPickupLeave",
        "onClientPlayerChangeNick",
        "onClientPlayerChoke",
        "onClientPlayerDamage",
        "onClientPlayerHeliKilled",
        "onClientPlayerHitByWaterCannon",
        "onClientPlayerJoin",
        "onClientPlayerPickupHit",
        "onClientPlayerPickupLeave",
        "onClientPlayerQuit",
        "onClientPlayerRadioSwitch",
        "onClientPlayerSpawn",
        "onClientPlayerStealthKill",
        "onClientPlayerStuntFinish",
        "onClientPlayerStuntStart",
        "onClientPlayerTarget",
        "onClientPlayerVehicleEnter",
        "onClientPlayerVehicleExit",
        "onClientPlayerVoicePause",
        "onClientPlayerVoiceResumed",
        "onClientPlayerVoiceStart",
        "onClientPlayerVoiceStop",
        "onClientPlayerWasted",
        "onClientPlayerWeaponFire",
        "onClientPlayerWeaponSwitch",
        "onClientObjectBreak",
        "onClientObjectDamage",
        "onClientObjectMoveStart",
        "onClientObjectMoveStop",
        "onClientProjectileCreation",
        "onClientResourceFileDownload",
        "onClientResourceStart",
        "onClientResourceStop",
        "onClientSoundBeat",
        "onClientSoundChangedMeta",
        "onClientSoundFinishedDownload",
        "onClientSoundStarted",
        "onClientSoundStopped",
        "onClientSoundStream",
        "onClientTrailerAttach",
        "onClientTrailerDetach",
        "onClientVehicleCollision",
        "onClientVehicleDamage",
        "onClientVehicleEnter",
        "onClientVehicleExit",
        "onClientVehicleExplode",
        "onClientVehicleNitroStateChange",
        "onClientVehicleRespawn",
        "onClientVehicleStartEnter",
        "onClientVehicleStartExit",
        "onClientVehicleWeaponHit",
        "onClientWeaponFire",
        "onClientChatMessage",
        "onClientConsole",
        "onClientCoreCommand",
        "onClientDebugMessage",
        "onClientExplosion",
        "onClientFileDownloadComplete",
        "onClientHUDRender",
        "onClientMinimize",
        "onClientMTAFocusChange",
        "onClientPedsProcessed",
        "onClientPlayerNetworkStatus",
        "onClientPreRender",
        "onClientRender",
        "onClientRestore",
        "onClientTransferBoxProgressChange",
        "onClientTransferBoxVisibilityChange",
        "onClientWorldSound",
    };

    private class EventData
    {
        public Regex regex { get; set; }
        public MatchEvaluator replace { get; set; }
    
        public EventData(Regex regex, MatchEvaluator replace)
        {
            this.regex = regex;
            this.replace = replace;
        }
    }

    private static string CompileEventName(string eventName)
    {
        if (ignoredEventNames.Contains(eventName))
            return eventName;
        
        return StringEncoder.ReverselessEncode(eventName, 128);
    }

    private List<EventData> events = new()
    {
        new EventData(new Regex(@"addEvent\((?:'([^']*)'|""([^""]*)"")"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"addEvent(\"{CompileEventName(eventName)}\"";
        }),
        new EventData(new Regex(@"addEventHandler\((?:'([^']*)'|""([^""]*)"")"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"addEventHandler(\"{CompileEventName(eventName)}\"";
        }),
        new EventData(new Regex(@"triggerServerEvent\((?:'([^']*)'|""([^""]*)"")"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerServerEvent(\"{CompileEventName(eventName)}\"";
        }),
        new EventData(new Regex(@"triggerEvent\((?:'([^']*)'|""([^""]*)"")"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerEvent(\"{CompileEventName(eventName)}\"";
        }),
        new EventData(new Regex(@"triggerLatentServerEvent\((?:'([^']*)'|""([^""]*)"")"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerLatentServerEvent(\"{CompileEventName(eventName)}\"";
        }),
        new EventData(new Regex(@"triggerClientEvent\(([^,]+),\s*(?:'([^']*)'|""([^""]*)""),"), (Match match) => {
            string eventName = match.Groups[2].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerClientEvent({match.Groups[1].Value}, \"{CompileEventName(eventName)}\",";
        }),
        new EventData(new Regex(@"triggerClientEvent\(\s*(?:'([^']*)'|""([^""]*)""),"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerClientEvent(\"{CompileEventName(eventName)}\",";
        }),
        new EventData(new Regex(@"triggerLatentClientEvent\(([^,]+),\s*(?:'([^']*)'|""([^""]*)""),"), (Match match) => {
            string eventName = match.Groups[2].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerLatentClientEvent({match.Groups[1].Value}, \"{CompileEventName(eventName)}\",";
        }),
        new EventData(new Regex(@"triggerLatentClientEvent\(\s*(?:'([^']*)'|""([^""]*)""),"), (Match match) => {
            string eventName = match.Groups[1].Value;
            Console.WriteLine($"Event: {eventName} -> {CompileEventName(eventName)}");
            return $"triggerLatentClientEvent(\"{CompileEventName(eventName)}\",";
        }),
    };

    public string path { get; set; }
    public string name { get; set; }
    public string outputName { get; set; }
    public ScriptType type { get; set; } = ScriptType.Shared;
    
    public MTAScript(string path, ScriptType type)
    {
        name = new DirectoryInfo(path).Name;
        outputName = Defines.compileScriptNames ? StringEncoder.ReverselessEncode(name, 64) : name;
        this.path = Path.GetDirectoryName(path) ?? string.Empty;
        this.type = type;
    }

    private string CompileExports(string source)
    {
        Regex regex = new Regex(@"exports\[(?:'([^']*)'|""([^""]*)"")\]");
        foreach (Match match in regex.Matches(source))
        {
            var export = match.Groups[1].Value;
            if (Defines.compileResourceNames)
            {
                export = StringEncoder.ReverselessEncode(export, 64);
            }

            var name = $"{Defines.resourceNameFooter}{export}";
            source = source.Replace(match.Value, $"exports[\"{name}\"]");
        }

        return source;
    }

    private string CompileEvents(string source)
    {
        foreach (var eventData in events)
        {
            source = eventData.regex.Replace(source, eventData.replace.Invoke);
        }
    
        return source;
    }

    public async Task<byte[]?> Compile(string resourcePath)
    {
        var scriptPath = Path.Combine(resourcePath, path, name);
        if (!File.Exists(scriptPath))
            return null;

        var script = await File.ReadAllTextAsync(scriptPath);
        script = CompileExports(script);
        if (Defines.compileEvents) script = CompileEvents(script);

        if (Defines.compileScripts)
        {
            var response = await _httpClient.PostAsync("https://luac.mtasa.com/?compile=1&debug=0&obfuscate=3", new StringContent(script));

            if (!response.IsSuccessStatusCode)
                return null;

            var buffer = await response.Content.ReadAsByteArrayAsync();
            var responseString = Encoding.UTF8.GetString(buffer);
            if (apiCodes.ContainsKey(responseString))
            {
                Console.WriteLine($"Failed to compile {name} with response: {responseString}");
                return null;
            }

            return buffer;
        }
        else
        {
            return Encoding.UTF8.GetBytes(script);
        }
    }
}