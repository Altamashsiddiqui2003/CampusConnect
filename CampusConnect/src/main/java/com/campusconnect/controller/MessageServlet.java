package com.campusconnect.controller;

import com.campusconnect.dao.MessageDAO;
import com.campusconnect.dao.UserDAO;
import com.campusconnect.model.Message;
import com.campusconnect.model.User;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet("/message")
public class MessageServlet extends HttpServlet {
    private MessageDAO messagedao;
    private UserDAO userdao;
    
    // Typing indicator storage
    private static final ConcurrentHashMap<String, Long> typingUsers = new ConcurrentHashMap<>();
    private static final long TYPING_TIMEOUT_MS = 3000; // 3 seconds

    @Override
    public void init() {
        messagedao = new MessageDAO();
        userdao = new UserDAO();
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
        
        String action = request.getParameter("action");
        
        if (action == null) {
            showMessages(request, response, currentUser);
        } else {
            switch (action) {
                case "chat":
                    showChat(request, response, currentUser);
                    break;
                case "poll":
                    pollMessages(request, response, currentUser);
                    break;
                case "recent":
                    getRecentChats(request, response, currentUser);
                    break;
                case "unreadCount":
                    getUnreadCount(request, response, currentUser);
                    break;
                case "markRead":
                    markMessagesAsRead(request, response, currentUser);
                    break;
                case "users":
                    searchUsers(request, response, currentUser);
                    break;
                default:
                    showMessages(request, response, currentUser);
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if (action == null) {
            sendMessage(request, response, currentUser);
        } else {
            switch (action) {
                case "send":
                    sendMessage(request, response, currentUser);
                    break;
                case "clear":
                    clearConversation(request, response, currentUser);
                    break;
                case "markRead":
                    markMessagesAsRead(request, response, currentUser);
                    break;
                case "typing":
                    handleTyping(request, response, currentUser);
                    break;
                default:
                    sendMessage(request, response, currentUser);
            }
        }
    }
    
    private void showMessages(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        try {
            List<User> chatUsers = messagedao.getChatUsers(currentUser.getUserId());
            
            // Get unread counts for each user
            Map<Integer, Integer> unreadCounts = new HashMap<>();
            for (User user : chatUsers) {
                int unread = messagedao.getUnreadMessageCount(currentUser.getUserId());
                unreadCounts.put(user.getUserId(), unread);
            }
            
            request.setAttribute("chatUsers", chatUsers);
            request.setAttribute("unreadCounts", unreadCounts);
            request.getRequestDispatcher("/messages.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }
    
    private void showChat(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            response.sendRedirect("messages?error=Invalid user ID");
            return;
        }
        
        try {
            int otherUserId = Integer.parseInt(userIdParam);
            User otherUser = userdao.getUserById(otherUserId);
            List<Message> messages = messagedao.getConversation(currentUser.getUserId(), otherUserId);
            
            // Mark messages as read when opening chat
            messagedao.markMessagesAsRead(otherUserId, currentUser.getUserId());
            
            request.setAttribute("otherUser", otherUser);
            request.setAttribute("messages", messages);
            request.getRequestDispatcher("/chat.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        } catch (NumberFormatException e) {
            response.sendRedirect("messages?error=Invalid user ID");
        }
    }
    
    private void sendMessage(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String receiverIdParam = request.getParameter("receiverId");
        String content = request.getParameter("content");
        
        if (receiverIdParam == null || content == null || content.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid parameters");
            return;
        }
        
        try {
            int receiverId = Integer.parseInt(receiverIdParam);
            Message message = new Message(currentUser.getUserId(), receiverId, content.trim());
            messagedao.createMessage(message);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Message sent successfully");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid receiver ID");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + e.getMessage());
        }
    }
    
    private void pollMessages(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String userIdParam = request.getParameter("userId");
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"messages\":[],\"otherTyping\":false}");
            return;
        }
        
        int otherUserId;
        try {
            otherUserId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"messages\":[],\"otherTyping\":false}");
            return;
        }
        
        long lastMessageId = 0;
        String lastMessageIdParam = request.getParameter("lastMessageId");
        if (lastMessageIdParam != null && !lastMessageIdParam.trim().isEmpty()) {
            try {
                lastMessageId = Long.parseLong(lastMessageIdParam);
            } catch (NumberFormatException e) {
                lastMessageId = 0;
            }
        }
        
        try {
            List<Message> messages = messagedao.getConversation(currentUser.getUserId(), otherUserId);
            
            List<Message> newMessages = new ArrayList<>();
            for (Message message : messages) {
                if (message.getMessageId() > lastMessageId) {
                    newMessages.add(message);
                }
            }
            
            // Check if other user is typing
            String otherKey = otherUserId + "_" + currentUser.getUserId();
            Long typingTime = typingUsers.get(otherKey);
            boolean isOtherTyping = false;
            if (typingTime != null) {
                if (System.currentTimeMillis() - typingTime < TYPING_TIMEOUT_MS) {
                    isOtherTyping = true;
                } else {
                    typingUsers.remove(otherKey); // expired
                }
            }
            
            response.setContentType("application/json");
            StringBuilder json = new StringBuilder();
            json.append("{\"messages\":[");
            for (int i = 0; i < newMessages.size(); i++) {
                Message m = newMessages.get(i);
                json.append("{")
                    .append("\"id\":").append(m.getMessageId())
                    .append(",\"content\":\"").append(escapeJson(m.getContent()))
                    .append("\",\"senderId\":").append(m.getSenderId())
                    .append(",\"timestamp\":\"").append(m.getCreatedAt() != null ? m.getCreatedAt().toString() : "")
                    .append("\"}");
                if (i < newMessages.size() - 1) json.append(",");
            }
            json.append("],\"otherTyping\":").append(isOtherTyping).append("}");
            response.getWriter().write(json.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"messages\":[],\"otherTyping\":false}");
        }
    }
    
    private void getRecentChats(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        try {
            List<Message> recentMessages = messagedao.getRecentConversations(currentUser.getUserId());
            
            response.setContentType("application/json");
            StringBuilder json = new StringBuilder("[");
            
            Map<Integer, Boolean> userAdded = new HashMap<>();
            int count = 0;
            
            for (int i = 0; i < recentMessages.size(); i++) {
                Message m = recentMessages.get(i);
                int otherUserId = (m.getSenderId() == currentUser.getUserId()) ? m.getReceiverId() : m.getSenderId();
                
                if (userAdded.containsKey(otherUserId)) {
                    continue;
                }
                userAdded.put(otherUserId, true);
                
                try {
                    User otherUser = userdao.getUserById(otherUserId);
                    if (otherUser != null) {
                        if (count > 0) json.append(",");
                        json.append("{")
                            .append("\"userId\":").append(otherUser.getUserId())
                            .append(",\"username\":\"").append(escapeJson(otherUser.getUserName()))
                            .append("\",\"fullName\":\"").append(escapeJson(otherUser.getFullName()))
                            .append("\",\"profilePicture\":\"").append(escapeJson(otherUser.getProfilePicture()))
                            .append("\",\"lastMessage\":\"").append(escapeJson(m.getContent()))
                            .append("\",\"lastMessageTime\":\"").append(m.getCreatedAt() != null ? m.getCreatedAt().toString() : "")
                            .append("\",\"unreadCount\":0")
                            .append("}");
                        count++;
                    }
                } catch (SQLException e) {
                    // skip
                }
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("[]");
        }
    }
    
    private void getUnreadCount(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        try {
            int totalUnread = messagedao.getUnreadMessageCount(currentUser.getUserId());
            response.setContentType("application/json");
            response.getWriter().write("{\"unreadCount\":" + totalUnread + "}");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"unreadCount\":0}");
        }
    }
    
    private void markMessagesAsRead(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String senderIdParam = request.getParameter("senderId");
        if (senderIdParam == null || senderIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid parameters");
            return;
        }
        try {
            int senderId = Integer.parseInt(senderIdParam);
            messagedao.markMessagesAsRead(senderId, currentUser.getUserId());
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Messages marked as read");
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid sender ID");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + e.getMessage());
        }
    }
    
    private void searchUsers(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String query = request.getParameter("query");
        try {
            List<User> users;
            if (query != null && !query.trim().isEmpty()) {
                users = userdao.searchUsers(query.trim());
            } else {
                users = userdao.getAllUsers();
            }
            List<User> filteredUsers = new ArrayList<>();
            for (User user : users) {
                if (user.getUserId() != currentUser.getUserId()) {
                    filteredUsers.add(user);
                }
            }
            response.setContentType("application/json");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < filteredUsers.size(); i++) {
                User user = filteredUsers.get(i);
                json.append("{")
                    .append("\"userId\":").append(user.getUserId())
                    .append(",\"username\":\"").append(escapeJson(user.getUserName()))
                    .append("\",\"fullName\":\"").append(escapeJson(user.getFullName()))
                    .append("\",\"profilePicture\":\"").append(escapeJson(user.getProfilePicture()))
                    .append("\"}");
                if (i < filteredUsers.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("[]");
        }
    }
    
    private void clearConversation(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String receiverIdParam = request.getParameter("receiverId");
        if (receiverIdParam == null || receiverIdParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid parameters");
            return;
        }
        try {
            int receiverId = Integer.parseInt(receiverIdParam);
            boolean success = messagedao.deleteConversation(currentUser.getUserId(), receiverId);
            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Conversation cleared");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to clear conversation");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Invalid receiver ID");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + e.getMessage());
        }
    }
    
    private void handleTyping(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws IOException {
        String receiverIdParam = request.getParameter("receiverId");
        String typingParam = request.getParameter("typing");
        if (receiverIdParam == null || typingParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        int receiverId = Integer.parseInt(receiverIdParam);
        String key = currentUser.getUserId() + "_" + receiverId;
        if ("true".equals(typingParam)) {
            typingUsers.put(key, System.currentTimeMillis());
        } else {
            typingUsers.remove(key);
        }
        response.setStatus(HttpServletResponse.SC_OK);
    }
    
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t")
                  .replace("/", "\\/");
    }
}