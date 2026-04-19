package com.campusconnect.controller;

import com.campusconnect.dao.PostDAO;
import com.campusconnect.model.Post;
import com.campusconnect.model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {
    private PostDAO postDao;
    
    @Override
    public void init() {
        postDao = new PostDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        System.out.println("=== HOME SERVLET ===");
        System.out.println("User: " + (user != null ? user.getUserName() : "null"));
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        try {
            // Get all posts first (for testing)
            List<Post> posts = postDao.getAllPosts(user.getUserId());
            
            System.out.println("Posts loaded: " + (posts != null ? posts.size() : "null"));
            
            if (posts != null) {
                for (Post post : posts) {
                    System.out.println("Post ID: " + post.getPostId() + ", User: " + post.getUser().getUserName());
                }
            }
            
            request.setAttribute("posts", posts);
            request.getRequestDispatcher("home.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("SQL Error: " + e.getMessage());
            request.setAttribute("error", "Error loading posts: " + e.getMessage());
            request.getRequestDispatcher("home.jsp").forward(request, response);
        }
    }
}