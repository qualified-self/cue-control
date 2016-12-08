import java.util.regex.Matcher;
import java.util.regex.Pattern;

class Utils {
  static String camelCaseToDash(String str) {
    return str.replaceAll("(.)(\\p{Upper})", "$1-$2").toLowerCase();
  }

  static String dashToCamelCase(String str) {
    Pattern p = Pattern.compile("-(.)");
    Matcher m = p.matcher(str);
    StringBuffer sb = new StringBuffer();
    while (m.find()) {
      m.appendReplacement(sb, m.group(1).toUpperCase());
    }
    m.appendTail(sb);
    String result = sb.toString();
    return result.substring(0, 1).toUpperCase() + result.substring(1);
  }
}
