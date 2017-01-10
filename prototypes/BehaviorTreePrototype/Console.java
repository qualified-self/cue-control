import java.util.ArrayList;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

class Console {

  public enum MessageType {
    NOTICE,
    WARNING,
    ERROR
  }

  public class Entry {
    private long timeStamp;
    private MessageType type;
    private String message;

    Entry(String message) {
      this(BehaviorTreePrototype.instance().millis(), MessageType.NOTICE, message);
    }

    Entry(MessageType type, String message) {
      this(BehaviorTreePrototype.instance().millis(), type, message);
    }

    Entry(long timeStamp, MessageType type, String message) {
      this.timeStamp = timeStamp;
      this.type = type;
      this.message = message;
    }

    long getTimeStamp() { return timeStamp; }
    MessageType getType() { return type; }
    String getMessage() { return message; }

    String getFormattedTime() {
      Date date = new Date(timeStamp);
      DateFormat formatter = new SimpleDateFormat("HH:mm:ss:SSS");
      return formatter.format(date);
    }
  }

  ArrayList<Entry> logs;

  static Console inst = new Console();

  Console() {
    logs = new ArrayList<Entry>();
  }

  public void log(String str) {
    logs.add(new Entry(str));
  }

  public void log(Object obj) {
    logs.add(new Entry(obj.toString()));
  }

  public void warning(String str) {
    logs.add(new Entry(MessageType.WARNING, str));
  }

  public void warning(Object obj) {
    logs.add(new Entry(MessageType.WARNING, obj.toString()));
  }

  public void error(String str) {
    logs.add(new Entry(MessageType.ERROR, str));
  }

  public void error(Object obj) {
    logs.add(new Entry(MessageType.ERROR, obj.toString()));
  }

  int nLogs() { return logs.size(); }

  public ArrayList<Entry> getLogs() { return logs; }

  public ArrayList<Entry> getLogs(int startIndex, int maxLogs) {
    if (nLogs() == 0)
      return new ArrayList<Entry>(0);

    startIndex = Math.min(startIndex, logs.size()-1);
    int endIndex = Math.min(startIndex+maxLogs, logs.size()-1);
//    System.out.println("Startindex: " + startIndex + " max "+ maxLogs + " end " + endIndex);
    ArrayList<Entry> result = new ArrayList<Entry>(endIndex-startIndex);
    for (int i=startIndex; i<=endIndex; i++)
      result.add(logs.get(i));
    return result;
  }

  public static Console instance() {
    return inst;
  }

}
