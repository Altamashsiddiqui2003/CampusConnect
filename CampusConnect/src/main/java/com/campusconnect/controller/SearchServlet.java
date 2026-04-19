package com.campusconnect.controller;

import com.campusconnect.dao.UserDAO;
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

@WebServlet("/searchs")
public class SearchServlet extends HttpServlet {
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
        
        String query = request.getParameter("q");
        
        if (query == null || query.trim().isEmpty()) {
            // Show empty search page if no query
            request.getRequestDispatcher("/search.jsp").forward(request, response);
            return;
        }
        
        try {
            List<User> users = userDAO.searchUsers(query.trim());
            request.setAttribute("users", users);
            request.setAttribute("searchQuery", query);
            request.getRequestDispatcher("/search.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Search error: " + e.getMessage());
            request.getRequestDispatcher("/search.jsp").forward(request, response);
        }
    }
}