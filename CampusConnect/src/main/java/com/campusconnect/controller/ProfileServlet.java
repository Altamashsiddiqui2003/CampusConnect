package com.campusconnect.controller;

import com.campusconnect.dao.CommentDAO;
import com.campusconnect.dao.UserDAO;
import com.campusconnect.model.User;
import java.io.IOException;
import java.sql.SQLException;
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

@WebServlet("/ProfileServlet")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5, // 5MB
    maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class ProfileServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        request.setAttribute("profileUser", user);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        User currentUser = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        
        System.out.println("Action: " + action);
        
        if ("update".equals(action)) {
            updateProfile(request, response, currentUser);
        } else if ("updatePhoto".equals(action)) {
            updateProfilePhoto(request, response, currentUser);
        } else {
            response.sendRedirect("profile.jsp?error=Invalid action");
        }
    }
    
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
    	HttpSession session = request.getSession(false);
        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String bio = request.getParameter("bio");
        
        System.out.println("Updating profile: " + username);
        
        // FIXED: setUserName() -> setUsername()
        currentUser.setFullName(fullName);
        currentUser.setUserName(username); // FIXED METHOD NAME
        currentUser.setEmail(email);
        currentUser.setBio(bio);
        
        try {
            if (userDAO.updateUser(currentUser)) {
                session.setAttribute("user", currentUser);
                response.sendRedirect("profile.jsp?success=Profile updated successfully");
            } else {
                response.sendRedirect("profile.jsp?error=Failed to update profile");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Database error: " + e.getMessage());
        }
    }
    
    private void updateProfilePhoto(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
    	HttpSession session = request.getSession(false);
        try {
            Part filePart = request.getPart("profilePhoto");
            
            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect("profile.jsp?error=No file selected");
                return;
            }
            
            // Get file info
            String fileName = getFileName(filePart);
            String contentType = filePart.getContentType();
            long fileSize = filePart.getSize();
            
            System.out.println("File upload: " + fileName + ", Type: " + contentType + ", Size: " + fileSize);
            
            // Validate file type
            if (!contentType.startsWith("image/")) {
                response.sendRedirect("profile.jsp?error=Only image files are allowed. Selected: " + contentType);
                return;
            }
            
            // Create uploads directory - FIXED PATH
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("Upload directory created: " + created + " at " + uploadPath);
            }
            
            // Generate unique filename
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
            String filePath = uploadPath + File.separator + uniqueFileName;
            
            System.out.println("Saving file to: " + filePath);
            
            // Save file
            filePart.write(filePath);
            
            // Update user profile picture path (relative path for web access)
            String profilePicturePath = "uploads/" + uniqueFileName;
            currentUser.setProfilePicture(profilePicturePath);
            
            if (userDAO.updateUserProfilePicture(currentUser.getUserId(), profilePicturePath)) {
                session.setAttribute("user", currentUser);
                response.sendRedirect("profile.jsp?success=Profile photo updated successfully");
            } else {
                response.sendRedirect("profile.jsp?error=Failed to update profile photo in database");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("profile.jsp?error=Upload error: " + e.getMessage());
        }
    }
    
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "unknown";
        
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown";
    }
    
 // In PostServlet - make sure this exists
    private void deleteComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
    	CommentDAO  commentDAO = new CommentDAO();
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String commentIdParam = request.getParameter("commentId");
        if (commentIdParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            int commentId = Integer.parseInt(commentIdParam);
            boolean deleted = commentDAO.deleteComment(commentId);
            if (deleted) {
                response.getWriter().write("deleted");
            } else {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}