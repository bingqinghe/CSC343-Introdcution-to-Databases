import java.sql.*;
import java.util.List;
import java.util.Properties;
import java.util.ArrayList;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
    	
    	try {
    		Properties props = new Properties();
    		props.setProperty("user", username);
    		props.setProperty("password", password);
    		props.setProperty("newschema", "parlgov");
    		connection = DriverManager.getConnection(url, props);
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception Connection." + "<Message>: " + se.getMessage());
    		return false;
    	}
        return true;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
    	try {
    		connection.close();
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception Disconnection." + "<Message>: " + se.getMessage());
    		return false;
    	}
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
    	List<Integer> elections = new ArrayList<Integer>();
    	List<Integer> cabinets = new ArrayList<Integer>();

    	try {
    		String queryString = "SELECT election.id, meetrequirement.cabinet_id " + 
    							 "FROM election NATURAL LEFT JOIN " +
    							 	"(SELECT country.id AS country_id, e1.id, " + 
    							 			"cabinet.id AS cabinet_id, cabinet.start_date " +
    							 	 "FROM country, cabinet, election AS e1 " +
    							 	 "WHERE country.name = ? AND " +
    							 	 	   "country.id = cabinet.country_id AND " +
    							 	 	   "country.id = e1.country_id AND " + 
    							 	 	   "cabinet.start_date >= e1.e_date AND " +
    							 	 	   	"(cabinet.start_date < (SELECT MIN(e2.e_date) " +
    							 	 	   						   "FROM election AS e2 " +
    							 	 	   						   "WHERE e1.country_id = e2.country_id AND " +
    							 	 	   						   		 "e1.e_type = e2.e_type AND " +
    							 	 	   						   		 "e1.e_date < e2.e_date) " +
    							 	 	   						   		 "OR NOT EXISTS (SELECT * FROM election AS e3 " +
    							 	 	   						   		 				"WHERE e1.country_id = e3.country_id AND " +
    							 	 	   						   		 					  "e1.e_type = e3.e_type AND " +
    							 	 	   						   		 					  "e1.e_date < e3.e_date))) AS meetrequirement " +
    							 "WHERE election.country_id = meetrequirement.country_id " +
    							 "ORDER BY election.e_date DESC, meetrequirement;";
    		PreparedStatement ps = connection.prepareStatement(queryString);
    		ps.setString(1, countryName);
    		ResultSet rs = ps.executeQuery();
    		
    		while(rs.next()) {
    			int get_election = rs.getInt(1);   			
    			if (rs.wasNull())
    				elections.add(null);
    			else
    				elections.add(get_election);
    			
    			int get_cabinet = rs.getInt(2);
    			if (rs.wasNull())
    				cabinets.add(null);
    			else
    				cabinets.add(get_cabinet);
    		}
    					
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception electionSequence." + "<Message>: " + se.getMessage());
    		System.exit(1);
    	}
    	
    	return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
    	List<Integer> answer = new ArrayList<Integer>();
    	
    	try {
    		String queryString = "SELECT t2.id, " + 
    									"t1.comment AS t1_c, t1.description AS t1_d, " +
    									"t2.comment AS t2_c, t2.description AS t2_d " + 
    							 "FROM politician_president AS t1, politician_president AS t2 " +
    							 "WHERE t1.id = ? AND t1.id != t2.id;";
    		PreparedStatement ps = connection.prepareStatement(queryString);
    		ps.setInt(1, politicianName);
    		ResultSet rs = ps.executeQuery();
    		
    		while(rs.next()) {
    			if(similarity(rs.getString(2) + " " + rs.getString(3),
    						  rs.getString(4) + " " + rs.getString(5)) >= threshold) {
    				answer.add(rs.getInt(1));
    			}
    		}
    	}
    	catch (SQLException se) {
    		System.err.println("SQL Exception findSimilarPoliticians." + "<Message>: " + se.getMessage());
    		System.exit(1);
    	}
        return answer;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

