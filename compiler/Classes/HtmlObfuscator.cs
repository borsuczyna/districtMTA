using System.Text;
using HtmlAgilityPack;
using System.Linq;
using System.Text.RegularExpressions;

public class HtmlObfuscator
{
    private HtmlDocument? doc;

    public string Obfuscate(string html)
    {
        doc = new HtmlDocument();
        doc.LoadHtml(html);

        // Remove comments
        doc.DocumentNode.Descendants()
            .Where(n => n.NodeType == HtmlNodeType.Comment)
            .ToList()
            .ForEach(n => n.Remove());

        // Obfuscate scripts
        var scripts = doc.DocumentNode.Descendants("script").ToList();
        foreach (var script in scripts)
        {
            var srcAttribute = script.Attributes["src"];
            if (srcAttribute != null)
                continue;

            var obfuscatedCode = JavaScriptObfuscator.Obfuscate(script.InnerHtml);
            if (obfuscatedCode == null)
                throw new Exception("Failed to obfuscate JavaScript code");

            var newScriptNode = HtmlNode.CreateNode($"<script>{obfuscatedCode}</script>");
            script.ParentNode.ReplaceChild(newScriptNode, script);
        }

        // Obfuscate CSS
        var styles = doc.DocumentNode.Descendants("style").ToList();
        foreach (var style in styles)
        {
            var minifiedCss = CSSMinifier.Minify(style.InnerHtml);
            var newStyleNode = HtmlNode.CreateNode($"<style>{minifiedCss}</style>");
            style.ParentNode.ReplaceChild(newStyleNode, style);
        }

        // Minify HTML
        var htmlOutput = doc.DocumentNode.WriteTo();
        return MinifyHtml(htmlOutput);
    }

    private string MinifyHtml(string html)
    {
        return Regex.Replace(html, @"\s+", " ")
                    .Replace("> <", "><")
                    .Trim();
    }
}