package ex;
public class Util {
    static { System.loadLibrary("util"); }
    //public static native String getCore();
    public static native int getCore();
    public static native void setCore(int newcore);
}
