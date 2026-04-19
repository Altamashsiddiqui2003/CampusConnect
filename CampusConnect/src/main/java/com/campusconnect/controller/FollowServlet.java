package com.campusconnect.controller;

import com.campusconnect.dao.UserDAO;
import com.campusconnect.model.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet("/follow")
public class FollowServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Please login to follow users\"}");
            return;
        }
        
        String action = request.getParameter("action");
        String targetUserIdParam = request.getParameter("targetUserId");
        
        // Validate parameters
        if (action == null || targetUserIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing parameters\"}");
            return;
        }
        
        try {
            int targetUserId = Integer.parseInt(targetUserIdParam);
            int currentUserId = currentUser.getUserId();
            
            // Prevent users from following themselves
            if (currentUserId == targetUserId) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Cannot follow yourself\"}");
                return;
            }
            
            boolean success = false;
            String message = "";
            
            switch (action.toLowerCase()) {
                case "follow":
                    success = userDAO.followUser(currentUserId, targetUserId);
                    message = success ? "Successfully followed user" : "Failed to follow user";
                    break;
                    
                case "unfollow":
                    success = userDAO.unfollowUser(currentUserId, targetUserId);
                    message = success ? "Successfully unfollowed user" : "Failed to unfollow user";
                    break;
                    
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Invalid action\"}");
                    return;
            }
            
            // Get updated follower count
            int followerCount = userDAO.getFollowerCount(targetUserId);
            int followingCount = userDAO.getFollowingCount(currentUserId);
            boolean isFollowing = userDAO.isFollowing(currentUserId, targetUserId);
            
            out.print(String.format(
                "{\"success\": %s, \"message\": \"%s\", \"followerCount\": %d, \"followingCount\": %d, \"isFollowing\": %s}",
                success, message, followerCount, followingCount, isFollowing
            ));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid user ID\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("check".equals(action)) {
            checkFollowStatus(request, response);
        } else if ("stats".equals(action)) {
            getFollowStats(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }
    
    private void checkFollowStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not logged in\"}");
            return;
        }
        
        String targetUserIdParam = request.getParameter("targetUserId");
        
        if (targetUserIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing target user ID\"}");
            return;
        }
        
        try {
            int targetUserId = Integer.parseInt(targetUserIdParam);
            int currentUserId = currentUser.getUserId();
            
            boolean isFollowing = userDAO.isFollowing(currentUserId, targetUserId);
            
            out.print(String.format(
                "{\"success\": true, \"isFollowing\": %s}",
                isFollowing
            ));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid user ID\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Database error\"}");
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }
    
    private void getFollowStats(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String userIdParam = request.getParameter("userId");
        
        if (userIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Missing user ID\"}");
            return;
        }
        
        try {
            int userId = Integer.parseInt(userIdParam);
            
            int followerCount = userDAO.getFollowerCount(userId);
            int followingCount = userDAO.getFollowingCount(userId);
            
            out.print(String.format(
                "{\"success\": true, \"followerCount\": %d, \"followingCount\": %d}",
                followerCount, followingCount
            ));
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid user ID\"}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Database error\"}");
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }
}