#include <SDL3/SDL.h>
#include <../SDL3_gfx/SDL3_gfxPrimitives.h>  // ajuste se o include for outro
#include <stdio.h>
#include <stdarg.h>

#ifdef _WIN32
#define SYSV __attribute__((sysv_abi))
#else
#define SYSV
#endif

/* ========== SDL3 ========== */

SYSV bool SDL_Init_sysv(SDL_InitFlags flags) {
    return SDL_Init(flags);
}

SYSV bool SDL_CreateWindowAndRenderer_sysv(const char *title, int width, int height,
                                           SDL_WindowFlags window_flags,
                                           SDL_Window **window, SDL_Renderer **renderer) {
    return SDL_CreateWindowAndRenderer(title, width, height, window_flags, window, renderer);
}

SYSV bool SDL_PollEvent_sysv(SDL_Event *event) {
    return SDL_PollEvent(event);
}

SYSV bool SDL_SetRenderDrawColor_sysv(SDL_Renderer *renderer, Uint8 r, Uint8 g, Uint8 b, Uint8 a) {
    return SDL_SetRenderDrawColor(renderer, r, g, b, a);
}

SYSV bool SDL_RenderClear_sysv(SDL_Renderer *renderer) {
    return SDL_RenderClear(renderer);
}

SYSV bool SDL_RenderPresent_sysv(SDL_Renderer *renderer) {
    return SDL_RenderPresent(renderer);
}

SYSV bool SDL_RenderLine_sysv(SDL_Renderer *renderer, float x1, float y1, float x2, float y2) {
    return SDL_RenderLine(renderer, x1, y1, x2, y2);
}

SYSV bool SDL_RenderFillRect_sysv(SDL_Renderer *renderer, const SDL_FRect *rect) {
    return SDL_RenderFillRect(renderer, rect);
}

SYSV void SDL_DelayPrecise_sysv(Uint64 ns) {
    SDL_DelayPrecise(ns);
}

SYSV Uint64 SDL_GetTicksNS_sysv(void) {
    return SDL_GetTicksNS();
}

SYSV void SDL_DestroyRenderer_sysv(SDL_Renderer *renderer) {
    SDL_DestroyRenderer(renderer);
}

SYSV void SDL_DestroyWindow_sysv(SDL_Window *window) {
    SDL_DestroyWindow(window);
}

SYSV void SDL_Quit_sysv(void) {
    SDL_Quit();
}

SYSV const char *SDL_GetError_sysv(void) {
    return SDL_GetError();
}

SYSV const bool *SDL_GetKeyboardState_sysv(int *numkeys) {
    return SDL_GetKeyboardState(numkeys);
}

/* ========== SDL3_gfx ========== */

SYSV int filledCircleRGBA_sysv(SDL_Renderer *renderer, float x, float y, float rad,
                               Uint8 r, Uint8 g, Uint8 b, Uint8 a) {
    return filledCircleRGBA(renderer, x, y, rad, r, g, b, a);
}