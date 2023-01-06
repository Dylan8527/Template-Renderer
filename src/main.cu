#include <iostream>
#include <cstdlib>
#include <chrono>
#include "utils.cuh"
#include <omp.h>
// ImGUI
#include <imgui.h>
#include <backends/imgui_impl_glfw.h>
#include <backends/imgui_impl_opengl3.h>
#include <ImGuizmo.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb_image_write.h>

const int WIDTH = 800;
const int HEIGHT = 600;

bool firstMouse = true;
float fov = 45.f;
float lastX = WIDTH / 2.f;
float lastY = HEIGHT / 2.f;

GLFWwindow *window;

void DrawContents(uint8_t *data);
uint8_t *GenerateRandomData(uint32_t size);

namespace Renderer
{
    bool show_demo_window = false;                            // Show demo window

    
    // Timer
    std::chrono::time_point<std::chrono::system_clock> start, end;
    std::chrono::duration<double> elapsed_seconds;
    double average_time = 0.0;
    double average_time_count = 0.0;

    void update_scale()
    {

    }

    void update()
    {

    }

    void processInput(GLFWwindow *window)
    {
        if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
            glfwSetWindowShouldClose(window, true);
    }

    void mouse_callback(GLFWwindow *window, double x, double y)
    {

    }

    void scroll_callback(GLFWwindow* window, double x, double y)
    {

    }

    //-------------------------opengl drawing-------------------------------------
    void RenderOpenGL()
    {
        start = std::chrono::system_clock::now();
        // auto data = GenerateRandomData(WIDTH * HEIGHT * 3);
        // DrawContents(data);
        // delete[] data;
        end = std::chrono::system_clock::now();
        elapsed_seconds = end - start;
        update();
    }

    //-------------------------imgui creation-------------------------------------
    void RenderMainImGui()
    {

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        // 1. Show the big demo window//
        if (show_demo_window)
            ImGui::ShowDemoWindow(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
        {
            ImGui::Begin("Template-Renderer Console"); // Create a window called "Hello, world!" and append into it.

            ImGui::Checkbox("Demo Window", &show_demo_window); // Edit bools storing our window open/close state

            average_time += elapsed_seconds.count();
            average_time_count += 1.0;

            // ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f * average_time / average_time_count, 1./average_time * average_time_count);
            ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
            ImGui::End();
        }

        // Rendering
        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    }
}

int main(int argc, char *argv[])
{
    WindowGuard windowGuard(window, WIDTH, HEIGHT, "Mandelbrot set explorer on GPU");
    glfwSetScrollCallback(window, Renderer::scroll_callback);
    glfwSetCursorPosCallback(window, Renderer::mouse_callback);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

    IMGUI_CHECKVERSION();
    ImGui::CreateContext(); // Setup Dear ImGui context
    ImGuiIO &io = ImGui::GetIO();
    (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;  // Enable Gamepad Controls

    ImGui::StyleColorsDark(); // Setup Dear ImGui style
    const char *glsl_version = "#version 130";
    ImGui_ImplGlfw_InitForOpenGL(window, true); // Setup Platform/Renderer bindings
    ImGui_ImplOpenGL3_Init(glsl_version);

    while (!glfwWindowShouldClose(window))
    {
        Renderer::processInput(window);

        Renderer::RenderOpenGL();
        Renderer::RenderMainImGui();

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}

void DrawContents(uint8_t *data)
{
    glDrawPixels(WIDTH, HEIGHT, GL_RGB, GL_UNSIGNED_BYTE, data);
}

uint8_t *GenerateRandomData(uint32_t size)
{
    uint8_t *data = new uint8_t[size];
#pragma omp parallel for
    for (int i = 0; i < size; i++)
        data[i] = static_cast<uint8_t>(rand());
    return data;
}