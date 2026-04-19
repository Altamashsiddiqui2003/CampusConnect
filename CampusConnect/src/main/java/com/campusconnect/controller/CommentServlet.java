package com.campusconnect.controller;

import com.campusconnect.dao.CommentDAO;
import com.campusconnect.model.Comment;
import com.campusconnect.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/comment")
public class CommentServlet extends HttpServlet {
    
    private CommentDAO commentDao;
    
    @Override
    public void init() {
        commentDao = new CommentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        System.out.println("CommentServlet GET - Action: " + action);
        
        if ("get".equals(action)) {
            getComments(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("Unauthorized");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("CommentServlet POST - Action: " + action);
        System.out.println("User ID: " + user.getUserId());
        
        if ("create".equals(action)) {
            createComment(request, response, user);
        } else if ("delete".equals(action)) {
            deleteComment(request, response, user);
        }  else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("Invalid action");
        }
    }
    
    private void getComments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int postId = Integer.parseInt(request.getParameter("postId"));
            System.out.println("Loading comments for post ID: " + postId);
            
            List<Comment> comments = commentDao.getCommentsByPostId(postId);
            request.setAttribute("comments", comments);
            
            // Forward to comments JSP fragment
            request.getRequestDispatcher("/comments.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid post ID");
        }
    }
    
    private void createComment(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        
        try {
            int postId = Integer.parseInt(request.getParameter("postId"));
            String content = request.getParameter("content");
            
            System.out.println("Creating comment - Post ID: " + postId + ", Content: " + content);
            
            Comment comment = new Comment(postId, user.getUserId(), content);
            commentDao.createComment(comment);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Comment created successfully");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid post ID");
        }
    }
    private void deleteComment(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        
        PrintWriter out = response.getWriter();
        System.out.println("=== DELETE COMMENT START ===");
        
        try {
            int commentId = Integer.parseInt(request.getParameter("commentId"));
            System.out.println("Deleting comment ID: " + commentId + " for user ID: " + user.getUserId());
            System.out.println("Request URL: " + request.getRequestURL());
            System.out.println("Query String: " + request.getQueryString());
            
            // Verify comment exists and user owns it
            Comment comment = commentDao.getCommentById(commentId);
            if (comment == null) {
                System.out.println("Comment not found");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("Comment not found");
                System.out.println("=== DELETE COMMENT END (Not Found) ===");
                return;
            }
            
            // Check if user owns the comment
            if (comment.getUserId() != user.getUserId()) {
                System.out.println("User not authorized to delete this comment");
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.write("Not authorized to delete this comment");
                System.out.println("=== DELETE COMMENT END (Forbidden) ===");
                return;
            }
            
            System.out.println("Comment found - User ID: " + comment.getUserId() + ", Match: " + (comment.getUserId() == user.getUserId()));
            
            // Delete comment
            boolean deleted = commentDao.deleteComment(commentId);
            
            if (deleted) {
                System.out.println("Comment deleted successfully");
                response.setStatus(HttpServletResponse.SC_OK);
                out.write("Comment deleted successfully");
                System.out.println("=== DELETE COMMENT END (Success) ===");
            } else {
                System.out.println("Delete failed");
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("Delete failed");
                System.out.println("=== DELETE COMMENT END (Failed) ===");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("Database error");
            System.out.println("=== DELETE COMMENT END (SQL Exception) ===");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("Invalid comment ID");
            System.out.println("=== DELETE COMMENT END (Number Format Exception) ===");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("Unexpected error: " + e.getMessage());
            System.out.println("=== DELETE COMMENT END (General Exception) ===");
        }
    }
    
}