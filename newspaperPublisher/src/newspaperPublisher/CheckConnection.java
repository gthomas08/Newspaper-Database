package newspaperPublisher;

import java.sql.*;
import javax.swing.*;

public class CheckConnection {
    Connection conn=null;   
    public static Connection ConnectDb() { 
        try{
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/newspaper_publisher", "root", "2635");
            //JOptionPane.showMessageDialog(null, "Connection to MySQL server/newspaper_publisher Established Successfully!"); 
            return conn;
           }
        catch(Exception e){
        JOptionPane.showMessageDialog(null,e);
        return null;
        }
    }
    
}
