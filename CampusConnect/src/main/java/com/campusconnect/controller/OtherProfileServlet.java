package com.campusconnect.controller;

import com.campusconnect.dao.UserDAO;
import com.campusconnect.dao.PostDAO;
import com.campusconnect.model.User;
import com.campusconnect.model.Post;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/other_profile")
public class OtherProfileServlet extends HttpServlet {
    private UserDAO userDAO;
    private PostDAO postDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
        postDAO = new PostDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String username = request.getParameter("username");
        
        if (username == null || username.isEmpty()) {
            response.sendRedirect("search?error=Username parameter missing");
            return;
        }
        
        try {
            // Get the profile user by username
            User profileUser = userDAO.getUserByUsername(username);
            if (profileUser == null) {
                response.sendRedirect("search?error=User not found");
                return;
            }
            
            // Get user stats
            int followersCount = userDAO.getFollowerCount(profileUser.getUserId());
            int followingCount = userDAO.getFollowingCount(profileUser.getUserId());
            List<Post> userPosts = postDAO.getPostsByUserId(profileUser.getUserId(), currentUser.getUserId());
            
            // Check if current user is following this profile user
            boolean isFollowing = userDAO.isFollowing(currentUser.getUserId(), profileUser.getUserId());
            
            // Set attributes for JSP
            request.setAttribute("profileUser", profileUser);
            request.setAttribute("userPosts", userPosts);
            request.setAttribute("followersCount", followersCount);
            request.setAttribute("followingCount", followingCount);
            request.setAttribute("isFollowing", isFollowing);
            
            // Forward to other_profile.jsp
            request.getRequestDispatcher("/other_profile.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("search?error=Database error");
        }
    }
}