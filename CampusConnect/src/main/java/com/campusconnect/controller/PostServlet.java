package com.campusconnect.controller;

import com.campusconnect.dao.PostDAO;
import com.campusconnect.dao.CommentDAO;
import com.campusconnect.model.Post;
import com.campusconnect.model.User;
import com.campusconnect.model.Comment;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.File;
import java.util.UUID;

@WebServlet("/postss")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10, // 10MB
    maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class PostServlet extends HttpServlet {
    private PostDAO postDAO;
    private CommentDAO commentDAO;
    private static final String UPLOAD_DIR = "uploads";
    
    @Override
    public void init() {
        postDAO = new PostDAO();
        commentDAO = new CommentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        System.out.println("=== POST SERVLET DOGET ===");
        System.out.println("Action: " + action);
        
        if ("delete".equals(action)) {
            deletePost(request, response);
        } else if ("comments".equals(action)) {
            getComments(request, response);
        } else if ("test".equals(action)) {
            createTestPost(request, response);
        } else {
            // Default to showing feed
            showFeed(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        System.out.println("=== POST SERVLET DOPOST ===");
        System.out.println("Action: " + action);
        
        if ("create".equals(action)) {
            createPost(request, response);
        } else if ("like".equals(action)) {
            likePost(request, response);
        } else if ("unlike".equals(action)) {
            unlikePost(request, response);
        } else if ("comment".equals(action)) {
            addComment(request, response);
        } else if ("delete".equals(action)) {
            deletePost(request, response);
        }
    }
    
    private void showFeed(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        System.out.println("=== SHOW FEED METHOD ===");
        System.out.println("User: " + (user != null ? user.getUserName() : "null"));
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Try to get posts from database
            List<Post> posts = postDAO.getAllPosts(user.getUserId());
            
            System.out.println("Posts from database: " + (posts != null ? posts.size() : "null"));
            
            // If no posts found, create some test posts
            if (posts == null || posts.isEmpty()) {
                System.out.println("No posts found in database, creating test posts");
                posts = createTestPosts(user);
            }
            
            // Ensure posts is never null
            if (posts == null) {
                posts = new ArrayList<>();
            }
            
            request.setAttribute("posts", posts);
            request.setAttribute("currentUser", user);
            
            System.out.println("Forwarding to home.jsp with " + posts.size() + " posts");
            request.getRequestDispatcher("/home.jsp").forward(request, response);
            
        } catch (SQLException e) {
            System.out.println("SQL Exception: " + e.getMessage());
            e.printStackTrace();
            
            // Even if database fails, show test posts
            List<Post> posts = createTestPosts(user);
            request.setAttribute("posts", posts);
            request.setAttribute("currentUser", user);
            request.setAttribute("error", "Database error, showing test data");
            request.getRequestDispatcher("/home.jsp").forward(request, response);
        }
    }
    
    // Method to create test posts
    private List<Post> createTestPosts(User user) {
        List<Post> posts = new ArrayList<>();
        
        // Create test post 1
        Post post1 = new Post();
        post1.setPostId(1);
        post1.setUserId(user.getUserId());
        post1.setContent("Welcome to CampusConnect! This is your first test post. Share your campus experiences and connect with other students!");
        post1.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
        post1.setLikeCount(5);
        post1.setCommentcount(2);
        post1.setLiked(false);
        
        User postUser1 = new User();
        postUser1.setUserId(user.getUserId());
        postUser1.setUserName(user.getUserName());
        postUser1.setFullName(user.getFullName());
        postUser1.setProfilePicture(user.getProfilePicture());
        post1.setUser(postUser1);
        
        // Create test post 2
        Post post2 = new Post();
        post2.setPostId(2);
        post2.setUserId(2);
        post2.setContent("Hello campus! Excited to connect with everyone here. Anyone going to the tech club meeting tomorrow?");
        post2.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis() - 3600000)); // 1 hour ago
        post2.setLikeCount(12);
        post2.setCommentcount(3);
        post2.setLiked(true);
        
        User postUser2 = new User();
        postUser2.setUserId(2);
        postUser2.setUserName("campus_user");
        postUser2.setFullName("Campus User");
        postUser2.setProfilePicture("https://via.placeholder.com/40");
        post2.setUser(postUser2);
        
        // Create test post 3
        Post post3 = new Post();
        post3.setPostId(3);
        post3.setUserId(3);
        post3.setContent("Just finished my final project! So relieved and excited to present it tomorrow. Good luck to everyone with their projects! 🎓");
        post3.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis() - 7200000)); // 2 hours ago
        post3.setLikeCount(25);
        post3.setCommentcount(8);
        post3.setLiked(false);
        
        User postUser3 = new User();
        postUser3.setUserId(3);
        postUser3.setUserName("study_buddy");
        postUser3.setFullName("Study Buddy");
        postUser3.setProfilePicture("https://via.placeholder.com/40");
        post3.setUser(postUser3);
        
        posts.add(post1);
        posts.add(post2);
        posts.add(post3);
        
        return posts;
    }
    
    private void createPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String content = request.getParameter("content");
        String imagePath = null;
        String videoPath = null;
        
        Part filePart = request.getPart("media");
        if (filePart != null && filePart.getSize() > 0) {
            String fileName = UUID.randomUUID().toString() + "_" + getFileName(filePart);
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            
            String filePath = uploadPath + File.separator + fileName;
            filePart.write(filePath);
            
            String mimeType = filePart.getContentType();
            if (mimeType != null && mimeType.startsWith("image/")) {
                imagePath = UPLOAD_DIR + "/" + fileName;
            } else if (mimeType != null && mimeType.startsWith("video/")) {
                videoPath = UPLOAD_DIR + "/" + fileName;
            }
        }
        
        Post post = new Post(user.getUserId(), content);
        post.setImagePath(imagePath);
        post.setVedioPath(videoPath);
        
        try {
            postDAO.createPost(post);
            response.sendRedirect("postss?success=Post created successfully!");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("postss?error=Error creating post. Please try again.");
        }
    }
    
    private void deletePost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String postIdParam = request.getParameter("postId");
        if (postIdParam == null) {
            response.sendRedirect("postss?error=Post ID required");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            Post post = postDAO.getPostById(postId, user.getUserId());
            if (post != null && post.getUserId() == user.getUserId()) {
                boolean deleted = postDAO.deletePost(postId);
                if (deleted) {
                    response.sendRedirect("postss?success=Post deleted successfully");
                } else {
                    response.sendRedirect("postss?error=Failed to delete post");
                }
            } else {
                response.sendRedirect("postss?error=You can only delete your own posts");
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("postss?error=Error deleting post");
        }
    }
    
    private void likePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String postIdParam = request.getParameter("postId");
        if (postIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            boolean success = postDAO.likePost(postId, user.getUserId());
            if (success) {
                response.getWriter().write("liked");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void unlikePost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String postIdParam = request.getParameter("postId");
        if (postIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            boolean success = postDAO.unlikePost(postId, user.getUserId());
            if (success) {
                response.getWriter().write("unliked");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    private void addComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String postIdParam = request.getParameter("postId");
        String content = request.getParameter("content");
        
        if (postIdParam == null || content == null || content.trim().isEmpty()) {
            response.sendRedirect("postss");
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            Comment comment = new Comment(postId, user.getUserId(), content.trim());
            commentDAO.createComment(comment);
            response.sendRedirect("postss?success=Comment added!");
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("postss?error=Error adding comment");
        }
    }
    
    private void getComments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String postIdParam = request.getParameter("postId");
        if (postIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            int postId = Integer.parseInt(postIdParam);
            List<Comment> comments = commentDAO.getCommentsByPostId(postId);
            
            request.setAttribute("comments", comments);
            request.getRequestDispatcher("/comments.jsp").forward(request, response);
            
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    // Temporary test method
    private void createTestPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user != null) {
            try {
                Post post = new Post();
                post.setUserId(user.getUserId());
                post.setContent("Test post created at " + new java.util.Date() + " - This is an automated test post to verify the system is working!");
                
                postDAO.createPost(post);
                response.sendRedirect("postss?success=Test post created successfully!");
                
            } catch (SQLException e) {
                response.sendRedirect("postss?error=Failed to create test post: " + e.getMessage());
            }
        } else {
            response.sendRedirect("login.jsp");
        }
    }
    
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) {
            return "";
        }
        
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}