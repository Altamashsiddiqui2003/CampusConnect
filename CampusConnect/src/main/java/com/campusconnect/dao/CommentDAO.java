package com.campusconnect.dao;

import com.campusconnect.model.Comment;
import com.campusconnect.model.User;
import com.campusconnect.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {
    
    public Comment createComment(Comment comment) throws SQLException {
        String sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, comment.getPostId());
            stmt.setInt(2, comment.getUserId());
            stmt.setString(3, comment.getContent());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        comment.setCommentId(rs.getInt(1));
                    }
                }
            }
        }
        return comment;
    }
    
    public List<Comment> getCommentsByPostId(int postId) throws SQLException {
        List<Comment> comments = new ArrayList<>();
        
        String sql = "SELECT c.*, u.username, u.full_name, u.profile_picture " +
                     "FROM comments c " +
                     "JOIN users u ON c.user_id = u.user_id " +
                     "WHERE c.post_id = ? " +
                     "ORDER BY c.created_at ASC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, postId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    comments.add(mapResultSetToComment(rs));
                }
            }
        }
        return comments;
    }
    
    public Comment getCommentById(int commentId) throws SQLException {
        String sql = "SELECT c.*, u.username, u.full_name, u.profile_picture " +
                     "FROM comments c " +
                     "JOIN users u ON c.user_id = u.user_id " +
                     "WHERE c.comment_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToComment(rs);
                }
            }
        }
        return null;
    }
    
    public boolean deleteComment(int commentId) throws SQLException {
        System.out.println("=== DELETE COMMENT DAO ===");
        System.out.println("Comment ID: " + commentId);
        
        String sql = "DELETE FROM comments WHERE comment_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Rows affected: " + rowsAffected);
            
            return rowsAffected > 0;
            
        }
        
    }
    
    public boolean directDeleteComment(int commentId) throws SQLException {
        System.out.println("=== DIRECT DELETE ===");
        
        String sql = "DELETE FROM comments WHERE comment_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, commentId);
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("Direct delete - Rows affected: " + rowsAffected);
            
            return rowsAffected > 0;
        }
    }
    
    private Comment mapResultSetToComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setCommentId(rs.getInt("comment_id"));
        comment.setPostId(rs.getInt("post_id"));
        comment.setUserId(rs.getInt("user_id"));
        comment.setContent(rs.getString("content"));
        comment.setCreatedAt(rs.getTimestamp("created_at"));
        
        User user = new User();
        user.setUserName(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setProfilePicture(rs.getString("profile_picture"));
        comment.setUser(user);
        
        return comment;
    }
}