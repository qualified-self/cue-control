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

  static State stringToState(String str) {
    str = str.toUpperCase();
  	if ("RUNNING".startsWith(str))        return State.RUNNING;
  	else if ("SUCCESS".startsWith(str))   return State.SUCCESS;
  	else if ("FAILURE".startsWith(str))   return State.FAILURE;
  	else if ("UNDEFINED".startsWith(str)) return State.UNDEFINED;
  	else return null;
  }

  static String stateToString(State state) {
  	if (state == State.RUNNING)        return "RUNNING";
  	else if (state == State.SUCCESS)   return "SUCCESS";
  	else if (state == State.FAILURE)   return "FAILURE";
  	else if (state == State.UNDEFINED) return "UNDEFINED";
    else return null;
  }
}
