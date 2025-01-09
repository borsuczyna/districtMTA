using System.Text.RegularExpressions;
using System.Threading.Tasks;

public static class CSSMinifier
{
    private static readonly Regex SelectCssComments = new(@"\/\*.*?\*\/", RegexOptions.Compiled); // Select comment blocks
    private static readonly Regex SelectCssLineBreaks = new(@"[\n\r]+\s*", RegexOptions.Compiled); // Select line breaks and subsequent space

    // Ensure content property values use quotation marks
    private static readonly Regex SelectCssContentValueWithApostrophes = new(@"content:\s*'([^']*)';", RegexOptions.Compiled); // Select content properties using apostrophes
    private static readonly Regex SelectCssContentValueWithSpacePrefix = new(@"content:\s{1,}""([^\""]*)"";", RegexOptions.Compiled); // Select content properties with space between the name and value
    private static readonly Regex SelectCssEmptyContentValueWithSpacePrefix = new(@"content:\s*""\s*"";", RegexOptions.Compiled); // Select empty content properties

    // All checks here are excluded if inside quotations marks
    private static readonly Regex SelectCssMultipleSpaces = new(@"\s+(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select multiple spaces
    private static readonly Regex SelectCssLastSemicolon = new(@";}(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select last semicolon and closing brace
    private static readonly Regex SelectCssSpaceThenClosingBrace = new(@"\s+}(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select spaces and closing brace
    private static readonly Regex SelectCssClosingBraceThenSpace = new(@"""}\s+(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select closing brace and spaces
    private static readonly Regex SelectCssSpaceThenOpeningBrace = new(@"\s+{(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select spaces before opening brace
    private static readonly Regex SelectCssOpeningBraceThenSpace = new(@"{\s+(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select opening brace and spaces
    private static readonly Regex SelectColonThenSpace = new(@":\s+(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select spaces between property and value
    private static readonly Regex SelectSpaceAfterComma = new(@",\s+(?![^""]*""(?:(?:[^""]*""){2})*[^""]*$)", RegexOptions.Compiled); // Select spaces after commas

    public static string Minify(string fileContent)
    {
        // Remove comments
        fileContent = SelectCssComments.Replace(fileContent, string.Empty);

        // Remove line breaks and subsequent spaces
        fileContent = SelectCssLineBreaks.Replace(fileContent, string.Empty);

        // Ensure content property values use consistent quotation marks
        fileContent = SelectCssContentValueWithApostrophes.Replace(fileContent, "content:\"$1\";");
        fileContent = SelectCssContentValueWithSpacePrefix.Replace(fileContent, "content:\"$1\";");
        fileContent = SelectCssEmptyContentValueWithSpacePrefix.Replace(fileContent, "content:\"\";");

        // Minify the CSS by removing unnecessary spaces and characters
        fileContent = SelectCssMultipleSpaces.Replace(fileContent, " ");
        fileContent = SelectCssLastSemicolon.Replace(fileContent, "}");
        fileContent = SelectCssSpaceThenClosingBrace.Replace(fileContent, "}");
        fileContent = SelectCssClosingBraceThenSpace.Replace(fileContent, "}");
        fileContent = SelectCssSpaceThenOpeningBrace.Replace(fileContent, "{");
        fileContent = SelectCssOpeningBraceThenSpace.Replace(fileContent, "{");
        fileContent = SelectColonThenSpace.Replace(fileContent, ":");
        fileContent = SelectSpaceAfterComma.Replace(fileContent, ",");

        return fileContent;
    }
}