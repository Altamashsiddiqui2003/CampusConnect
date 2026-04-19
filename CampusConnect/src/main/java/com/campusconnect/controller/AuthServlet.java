package com.campusconnect.controller;

import com.campusconnect.dao.UserDAO;
import com.campusconnect.model.User;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/auth")
public class AuthServlet extends HttpServlet {
	private UserDAO userDAO;

	@Override
	public void init() {
		userDAO = new UserDAO();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getParameter("action");
		System.out.println("AuthServlet: Processing POST action - " + action);

		if ("login".equals(action)) {
			login(request, response);
		} else if ("register".equals(action)) {
			register(request, response);
		} else {
			response.sendRedirect("login.jsp");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getParameter("action");
		System.out.println("AuthServlet: Processing GET action - " + action);

		if ("logout".equals(action)) {
			logout(request, response);
		} else {
			response.sendRedirect("login.jsp");
		}
	}

	private void login(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");

		System.out.println("Login attempt for user: " + username);

		// Validate input
		if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
			request.setAttribute("error", "Username and password are required");
			request.getRequestDispatcher("/login.jsp").forward(request, response);
			return;
		}

		try {
			User user = userDAO.getUserByUsername(username.trim());
			if (user != null && BCrypt.checkpw(password, user.getPassWord())) {
				// Create new session
				HttpSession oldSession = request.getSession(false);
				if (oldSession != null) {
					oldSession.invalidate();
				}

				HttpSession newSession = request.getSession(true);
				newSession.setAttribute("user", user);
				newSession.setMaxInactiveInterval(30 * 60); // 30 minutes

				System.out.println("Login successful for user: " + user.getUserName());
				System.out.println("Session ID: " + newSession.getId());

				// Redirect to posts page
				response.sendRedirect("home.jsp");
			} else {
				System.out.println("Login failed - invalid credentials");
				request.setAttribute("error", "Invalid username or password");
				request.getRequestDispatcher("/login.jsp").forward(request, response);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			request.setAttribute("error", "Database error. Please try again.");
			request.getRequestDispatcher("/login.jsp").forward(request, response);
		}
	}

	private void register(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String username = request.getParameter("username");
		String email = request.getParameter("email");
		String password = request.getParameter("password");
		String fullName = request.getParameter("fullName");

		System.out.println("Registration attempt for user: " + username);

		// Validate all required parameters
		if (username == null || email == null || password == null || fullName == null || username.trim().isEmpty()
				|| email.trim().isEmpty() || password.trim().isEmpty() || fullName.trim().isEmpty()) {
			request.setAttribute("error", "All fields are required");
			request.getRequestDispatcher("/register.jsp").forward(request, response);
			return;
		}

		try {
			// Check if username already exists
			if (userDAO.getUserByUsername(username.trim()) != null) {
				request.setAttribute("error", "Username already exists");
				request.getRequestDispatcher("/register.jsp").forward(request, response);
				return;
			}

			// Check if email already exists
			User existingUser = userDAO.getUserByEmail(email.trim());
			if (existingUser != null) {
				request.setAttribute("error", "Email already registered");
				request.getRequestDispatcher("/register.jsp").forward(request, response);
				return;
			}

			// Create new user
			String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
			User user = new User(username.trim(), email.trim(), hashedPassword, fullName.trim());
			user = userDAO.createUser(user);

			if (user.getUserId() > 0) {
				// Create new session
				HttpSession oldSession = request.getSession(false);
				if (oldSession != null) {
					oldSession.invalidate();
				}

				HttpSession newSession = request.getSession(true);
				newSession.setAttribute("user", user);
				newSession.setMaxInactiveInterval(30 * 60);

				System.out.println("Registration successful for user: " + user.getUserName());
				System.out.println("Session ID: " + newSession.getId());

				// Redirect to posts page
				response.sendRedirect("posts.jsp");
			} else {
				request.setAttribute("error", "Registration failed");
				request.getRequestDispatcher("/register.jsp").forward(request, response);
			}
		} catch (SQLException e) {
			e.printStackTrace();
			request.setAttribute("error", "Registration error: " + e.getMessage());
			request.getRequestDispatcher("/register.jsp").forward(request, response);
		}
	}

	private void logout(HttpServletRequest request, HttpServletResponse response) throws IOException {

		HttpSession session = request.getSession(false);
		if (session != null) {
			session.invalidate();
			System.out.println("User logged out successfully");
		}
		response.sendRedirect("login.jsp");
	}
}