package com.campusconnect.dao;

import com.campusconnect.model.User;
import com.campusconnect.model.Message;
import com.campusconnect.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {
    
    // Create A Message 
    public Message createMessage(Message message) throws SQLException {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, message.getSenderId());
            stmt.setInt(2, message.getReceiverId());
            stmt.setString(3, message.getContent());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        message.setMessageId(rs.getInt(1));
                    }
                }
            }
        }
        return message;
    }
    
    public List<Message> getConversation(int user1Id, int user2Id) throws SQLException {
        List<Message> messages = new ArrayList<>();
        
        String sql ="SELECT m.*, s.username as sender_username, s.profile_picture as sender_profile,\r\n"
                + "                   r.username as receiver_username, r.profile_picture as receiver_profile\r\n"
                + "            FROM messages m\r\n"
                + "            JOIN users s ON m.sender_id = s.user_id\r\n"
                + "            JOIN users r ON m.receiver_id = r.user_id\r\n"
                + "            WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)\r\n"
                + "            ORDER BY m.created_at ASC";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, user1Id);
            stmt.setInt(2, user2Id);
            stmt.setInt(3, user2Id);
            stmt.setInt(4, user1Id);
            
            try(ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                     messages.add(mapResultSetToMessage(rs));
                }
            }
        }
        return messages;
    }
    
    // NEW METHOD: Get recent conversations for a user
    public List<Message> getRecentConversations(int userId) throws SQLException {
        List<Message> recentMessages = new ArrayList<>();
        
        // Get the most recent message from each conversation
        String sql = "SELECT m1.*, s.username as sender_username, s.profile_picture as sender_profile, " +
                     "r.username as receiver_username, r.profile_picture as receiver_profile " +
                     "FROM messages m1 " +
                     "JOIN users s ON m1.sender_id = s.user_id " +
                     "JOIN users r ON m1.receiver_id = r.user_id " +
                     "WHERE m1.created_at = ( " +
                     "    SELECT MAX(created_at) FROM messages m2 " +
                     "    WHERE (m2.sender_id = m1.sender_id AND m2.receiver_id = m1.receiver_id) " +
                     "       OR (m2.sender_id = m1.receiver_id AND m2.receiver_id = m1.sender_id) " +
                     ") " +
                     "AND (m1.sender_id = ? OR m1.receiver_id = ?) " +
                     "ORDER BY m1.created_at DESC";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            
            try(ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                    recentMessages.add(mapResultSetToMessage(rs));
                }
            }
        }
        return recentMessages;
    }
    
    // Alternative simpler method for recent chats
    public List<Message> getRecentChats(int userId) throws SQLException {
        List<Message> recentMessages = new ArrayList<>();
        
        String sql = "SELECT DISTINCT ON ( " +
                     "    CASE " +
                     "        WHEN sender_id = ? THEN receiver_id " +
                     "        ELSE sender_id " +
                     "    END " +
                     ") m.*, s.username as sender_username, s.profile_picture as sender_profile, " +
                     "r.username as receiver_username, r.profile_picture as receiver_profile " +
                     "FROM messages m " +
                     "JOIN users s ON m.sender_id = s.user_id " +
                     "JOIN users r ON m.receiver_id = r.user_id " +
                     "WHERE sender_id = ? OR receiver_id = ? " +
                     "ORDER BY (CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END), created_at DESC";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);
            stmt.setInt(4, userId);
            
            try(ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                    recentMessages.add(mapResultSetToMessage(rs));
                }
            }
        }
        return recentMessages;
    }
    
    public List<User> getChatUsers(int userId) throws SQLException {
        List<User> users = new ArrayList<>();
        
        String sql ="SELECT DISTINCT u.* FROM users u\r\n"
                + "            WHERE u.user_id IN (\r\n"
                + "                SELECT sender_id FROM messages WHERE receiver_id = ?\r\n"
                + "                UNION\r\n"
                + "                SELECT receiver_id FROM messages WHERE sender_id = ?\r\n"
                + "            )";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            
            try(ResultSet rs = stmt.executeQuery()) {
                while(rs.next()) {
                    User user = new User();
                    
                    user.setUserId(rs.getInt("user_id"));
                    user.setUserName(rs.getString("username"));
                    user.setFullName(rs.getString("full_name"));
                    user.setProfilePicture(rs.getString("profile_picture"));
                    users.add(user);
                }
            }
        }
        return users;
    }

    
    public void markMessagesAsRead(int senderId,int receiverId) throws SQLException {
        String sql = "UPDATE messages SET is_read = TRUE WHERE sender_id = ? AND receiver_id = ? AND is_read = FALSE";

        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, senderId);
            stmt.setInt(2, receiverId);
            stmt.executeUpdate();
        }
    }
    
    public int getUnreadMessageCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = FALSE";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            try(ResultSet rs = stmt.executeQuery()) {
                if(rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    
    // NEW METHOD: Delete conversation between two users
    public boolean deleteConversation(int user1Id, int user2Id) throws SQLException {
        String sql = "DELETE FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, user1Id);
            stmt.setInt(2, user2Id);
            stmt.setInt(3, user2Id);
            stmt.setInt(4, user1Id);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    // NEW METHOD: Get last message with a specific user
    public Message getLastMessageWithUser(int user1Id, int user2Id) throws SQLException {
        String sql = "SELECT m.*, s.username as sender_username, s.profile_picture as sender_profile, " +
                     "r.username as receiver_username, r.profile_picture as receiver_profile " +
                     "FROM messages m " +
                     "JOIN users s ON m.sender_id = s.user_id " +
                     "JOIN users r ON m.receiver_id = r.user_id " +
                     "WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?) " +
                     "ORDER BY m.created_at DESC LIMIT 1";
        
        try(Connection conn = DatabaseUtil.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, user1Id);
            stmt.setInt(2, user2Id);
            stmt.setInt(3, user2Id);
            stmt.setInt(4, user1Id);
            
            try(ResultSet rs = stmt.executeQuery()) {
                if(rs.next()) {
                    return mapResultSetToMessage(rs);
                }
            }
        }
        return null;
    }
    
    private Message mapResultSetToMessage(ResultSet rs) throws SQLException {
        Message message = new Message();
        
        message.setMessageId(rs.getInt("message_id"));
        message.setSenderId(rs.getInt("sender_id"));
        message.setReceiverId(rs.getInt("receiver_id"));
        message.setContent(rs.getString("content"));
        message.setRead(rs.getBoolean("is_read"));
        message.setCreatedAt(rs.getTimestamp("created_at"));
        
        User sender = new User();
        sender.setUserName(rs.getString("sender_username"));
        sender.setProfilePicture(rs.getString("sender_profile"));
        message.setSender(sender);
        
        User receiver = new User();
        receiver.setUserName(rs.getString("receiver_username"));
        receiver.setProfilePicture(rs.getString("receiver_profile"));
        message.setReceiver(receiver);
        
        return message;
    }
}