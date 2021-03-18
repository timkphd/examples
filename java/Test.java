import ex.Util;
public class Test {
    public static void main(String[] args) {
            System.out.println("   Initial core: "+Util.getCore());
            int mycore=7;
            System.out.println("Requesting core: "+mycore);
            Util.setCore(mycore);
            System.out.println("    Now on core: "+Util.getCore());
    }
}

