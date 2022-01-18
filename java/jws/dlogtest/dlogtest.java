
import java.applet.*;
import java.awt.*;

public class dlogtest extends Applet {
        Frame dFrame = null;
        Dialog dDialog = null;

        public void init() {
                dFrame = ComponentUtil.getFrame(this);
                dDialog = new AlertDialog(dFrame, "This is a test.");
                dDialog.reshape(100, 100, 200, 100);
                dDialog.show();
        }
}

class AlertDialog extends Dialog {
        public AlertDialog(Frame parent, String message) {
                super(parent, "Alert!", true);
                add("Center", new Label(message));
                Panel thePanel = new Panel();
                thePanel.add(new Button("Ok"));
                add("South", thePanel);
        }

        public boolean action(Event evt, Object arg) {
                if ("Ok".equals(arg)) {
                        dispose();
                }
                return true;
        }
}

class ComponentUtil {
        public static Frame getFrame(Component theComponent) {
                Component currParent = theComponent;
                Frame theFrame = null;

                while (currParent != null) {
                        if (currParent instanceof Frame) {
                                theFrame = (Frame)currParent;
                                break;
                        }
                        currParent = currParent.getParent();
                }

                return theFrame;
        }
}

