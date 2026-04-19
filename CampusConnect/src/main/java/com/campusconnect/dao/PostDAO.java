package com.campusconnect.dao;

import com.campusconnect.model.Post;
import com.campusconnect.model.User;
import com.campusconnect.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {
	
	public Post createPost(Post post) throws SQLException {
	    String sql = "INSERT INTO posts (user_id, content, image_path, video_path) VALUES (?, ?, ?, ?)";
	    
	    try (Connection conn = DatabaseUtil.getConnection();
	         // FIX: Add Statement.RETURN_GENERATED_KEYS
	         PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
	        
	        stmt.setInt(1, post.getUserId());
	        stmt.setString(2, post.getContent());
	        stmt.setString(3, post.getImagePath());
	        stmt.setString(4, post.getVedioPath());
	        
	        int affectedRows = stmt.executeUpdate();
	        if (affectedRows > 0) {
	            try (ResultSet rs = stmt.getGeneratedKeys()) {
	                if (rs.next()) {
	                    post.setPostId(rs.getInt(1));
	                }
	            }
	        }
	    }
	    return post;
	}

	public List<Post> getPostsByUserId(int userId , int currentUserId) throws SQLException
	{
		List<Post> posts = new ArrayList<>();
		String sql ="SELECT p.*, u.username, u.full_name, u.profile_picture,\r\n"
				+ "                   (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id) as like_count,\r\n"
				+ "                   (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.post_id) as comment_count,\r\n"
				+ "                   EXISTS(SELECT 1 FROM likes l WHERE l.post_id = p.post_id AND l.user_id = ?) as is_liked\r\n"
				+ "            FROM posts p\r\n"
				+ "            JOIN users u ON p.user_id = u.user_id\r\n"
				+ "            WHERE p.user_id = ?\r\n"
				+ "            ORDER BY p.created_at DESC";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement  stmt = conn.prepareStatement(sql))
		{
			stmt.setInt(1, currentUserId);
			stmt.setInt(2, userId);
			
			try(ResultSet rs = stmt.executeQuery())
			{
				while(rs.next())
				{
					 posts.add(mapResultSetToPost(rs));
				}
			}
		}
		return posts;
		
	}
	
	public List<Post> getFeedPosts(int userId) throws SQLException 
	{
		List<Post> posts = new ArrayList<>();
		
		String sql ="SELECT p.*, u.username, u.full_name, u.profile_picture,\r\n"
				+ "                   (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id) as like_count,\r\n"
				+ "                   (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.post_id) as comment_count,\r\n"
				+ "                   EXISTS(SELECT 1 FROM likes l WHERE l.post_id = p.post_id AND l.user_id = ?) as is_liked\r\n"
				+ "            FROM posts p\r\n"
				+ "            JOIN users u ON p.user_id = u.user_id\r\n"
				+ "            WHERE p.user_id = ? OR p.user_id IN (\r\n"
				+ "                SELECT following_id FROM follows WHERE follower_id = ?\r\n"
				+ "            )\r\n"
				+ "            ORDER BY p.created_at DESC\r\n"
				+ "            LIMIT 50";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement  stmt = conn.prepareStatement(sql))
		{
			stmt.setInt(1, userId);
			stmt.setInt(2, userId);
			stmt.setInt(3, userId);
			
			try(ResultSet rs = stmt.executeQuery())
			{
				while(rs.next())
				{
					 posts.add(mapResultSetToPost(rs));
				}
			}
		}
		return posts;
	}
	
	public Post getPostById(int postId, int currentUserId) throws SQLException
	{
		
		String sql="   SELECT p.*, u.username, u.full_name, u.profile_picture,\r\n"
				+ "                   (SELECT COUNT(*) FROM likes l WHERE l.post_id = p.post_id) as like_count,\r\n"
				+ "                   (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.post_id) as comment_count,\r\n"
				+ "                   EXISTS(SELECT 1 FROM likes l WHERE l.post_id = p.post_id AND l.user_id = ?) as is_liked\r\n"
				+ "            FROM posts p\r\n"
				+ "            JOIN users u ON p.user_id = u.user_id\r\n"
				+ "            WHERE p.post_id = ?";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql))
		{
			stmt.setInt(1, currentUserId);
			stmt.setInt(2, postId);
			
			try(ResultSet rs = stmt.executeQuery())
			{
				while(rs.next())
				{
					return mapResultSetToPost(rs);
				}
			}
		}
		
		return null;
	}
	
	public boolean updatePost(Post post) throws SQLException 
	{
		String sql = "UPDATE posts SET content = ?, image_path = ?, video_path = ? WHERE post_id = ?";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql))
		{
			stmt.setString(1, post.getContent());
			stmt.setString(2,post.getImagePath());
			stmt.setString(3, post.getVedioPath());
			stmt.setInt(4, post.getPostId());
			
			return stmt.executeUpdate()>0;
			
		}
		
		
	}
	
	
	public boolean deletePost(int postId) throws SQLException
	{
		String sql = "DELETE FROM posts WHERE post_id = ?";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql))
		{
			stmt.setInt(1, postId);
			
			return stmt.executeUpdate()>0;
			
		}
	}
	
	public boolean likePost(int postId, int userId) throws SQLException 
	{
		
		String sql ="INSERT IGNORE INTO likes (post_id, user_id) VALUES (?, ?)";
		
		try(Connection conn = DatabaseUtil.getConnection();
				PreparedStatement stmt = conn.prepareStatement(sql))
		{
			stmt.setInt(1, postId);
			stmt.setInt(2, userId);
			
			return stmt.executeUpdate()>0;
			
			
		}
	}
	
	public boolean unlikePost(int postId,int userId) throws SQLException 
	{
		 String sql = "DELETE FROM likes WHERE post_id = ? AND user_id = ?";
		 
		 try(Connection conn = DatabaseUtil.getConnection();
				 PreparedStatement stmt = conn.prepareStatement(sql))
		 {
			 
			 stmt.setInt(1, postId);
			 stmt.setInt(2, userId);
			 
			 return stmt.executeUpdate()>0;
			 
		 }
	}
	
	private Post mapResultSetToPost(ResultSet rs) throws SQLException 
	{
		Post post = new Post();
		
		post.setPostId(rs.getInt("post_id"));
        post.setUserId(rs.getInt("user_id"));
        post.setContent(rs.getString("content"));
        post.setImagePath(rs.getString("image_path"));
        post.setVedioPath(rs.getString("video_path"));
        post.setCreatedAt(rs.getTimestamp("created_at"));
        post.setUpdatedAt(rs.getTimestamp("updated_at"));
        post.setLikeCount(rs.getInt("like_count"));
        post.setCommentcount(rs.getInt("comment_count"));
        post.setLiked(rs.getBoolean("is_liked"));
        
     // Set user info
        
        User user = new User();
        user.setUserName(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setProfilePicture(rs.getString("profile_picture"));
        post.setUser(user);
        
        return post;
	
	}
	
	public List<Post> getAllPosts(int currentUserId) throws SQLException {
	    List<Post> posts = new ArrayList<>();
	    
	    String sql = "SELECT p.*, u.username, u.full_name, u.profile_picture, " +
	                 "EXISTS(SELECT 1 FROM likes l WHERE l.post_id = p.post_id AND l.user_id = ?) as is_liked, " +
	                 "(SELECT COUNT(*) FROM likes WHERE post_id = p.post_id) as like_count, " +
	                 "(SELECT COUNT(*) FROM comments WHERE post_id = p.post_id) as comment_count " +
	                 "FROM posts p " +
	                 "JOIN users u ON p.user_id = u.user_id " +
	                 "ORDER BY p.created_at DESC";
	    
	    try (Connection conn = DatabaseUtil.getConnection();
	         PreparedStatement stmt = conn.prepareStatement(sql)) {
	        
	        stmt.setInt(1, currentUserId);
	        
	        try (ResultSet rs = stmt.executeQuery()) {
	            while (rs.next()) {
	                Post post = new Post();
	                post.setPostId(rs.getInt("post_id"));
	                post.setUserId(rs.getInt("user_id"));
	                post.setContent(rs.getString("content"));
	                post.setImagePath(rs.getString("image_path"));
	                post.setVedioPath(rs.getString("video_path"));
	                post.setCreatedAt(rs.getTimestamp("created_at"));
	                post.setLiked(rs.getBoolean("is_liked"));
	                post.setLikeCount(rs.getInt("like_count"));
	                post.setCommentcount(rs.getInt("comment_count"));
	                
	                // Set user info
	                User postUser = new User();
	                postUser.setUserId(rs.getInt("user_id"));
	                postUser.setUserName(rs.getString("username"));
	                postUser.setFullName(rs.getString("full_name"));
	                postUser.setProfilePicture(rs.getString("profile_picture"));
	                post.setUser(postUser);
	                
	                posts.add(post);
	            }
	        }
	    }
	    return posts;
	}
	
	
}
