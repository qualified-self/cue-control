import java.util.ArrayList;

class Console {
  ArrayList<String> logs;

  static Console inst = new Console();

  Console() {
    logs = new ArrayList<String>();
  }

  public void log(String str) {
    logs.add(str);
  }

  public void log(Object obj) {
    logs.add(obj.toString());
  }

  int nLogs() { return logs.size(); }

  public ArrayList<String> getLogs() { return logs; }

  public ArrayList<String> getLogs(int startIndex, int maxLogs) {
    if (nLogs() == 0)
      return new ArrayList<String>(0);

    startIndex = Math.min(startIndex, logs.size()-1);
    int endIndex = Math.min(startIndex+maxLogs, logs.size()-1);
//    System.out.println("Startindex: " + startIndex + " max "+ maxLogs + " end " + endIndex);
    ArrayList<String> result = new ArrayList<String>(endIndex-startIndex);
    for (int i=startIndex; i<=endIndex; i++)
      result.add(logs.get(i));
    return result;
  }

  public static Console instance() {
    return inst;
  }

}
