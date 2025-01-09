using System.Security.Cryptography;
using System.Text;

public class StringEncoder
{
    public static string key = "district";

    public static string Encode(string str)
    {
        return XTEA.Encrypt(str, key);
    }

    public static string ReverselessEncode(string str, int maxLength)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(str);
        byte[] hash = MD5.Create().ComputeHash(bytes);
        return BitConverter.ToString(hash).Replace("-", "").ToLower();
    }

    public static string Decode(string str)
    {
        return XTEA.Decrypt(str, key);
    }
}