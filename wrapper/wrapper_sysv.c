#include <SDL3/SDL.h>
#include <SDL3_ttf/SDL_ttf.h>
#include <../SDL_mixer/include/SDL3_mixer/SDL_mixer.h>
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

/* =========== SDL AUDIO ============ */

SYSV bool SDL_LoadWAV_sysv(const char *path, SDL_AudioSpec *spec, Uint8 **audio_buf, Uint32 *audio_len)
{
    return SDL_LoadWAV(path, spec, audio_buf, audio_len);
}

SYSV SDL_AudioStream * SDL_OpenAudioDeviceStream_sysv(SDL_AudioDeviceID devid, const SDL_AudioSpec *spec, SDL_AudioStreamCallback callback, void *userdata)
{
    return SDL_OpenAudioDeviceStream(devid, spec, callback, userdata);
}

SYSV bool SDL_PutAudioStreamData_sysv(SDL_AudioStream *stream, const void *buf, int len)
{
    return SDL_PutAudioStreamData(stream, buf, len);
}

SYSV bool SDL_ResumeAudioStreamDevice_sysv(SDL_AudioStream *stream)
{
    return SDL_ResumeAudioStreamDevice(stream);
}

SYSV void SDL_DestroyAudioStream_sysv(SDL_AudioStream *stream)
{
    return SDL_DestroyAudioStream(stream);
}

SYSV void SDL_free_sysv(void *mem)
{
    return SDL_free(mem);
}

SYSV const char *SDL_GetBasePath_sysv(void) {
    return SDL_GetBasePath();
}

SYSV int SDL_asprintf_sysv(char **strp, const char *fmt, const char *arg1, const char *arg2)
{
    return SDL_asprintf(strp, fmt, arg1, arg2);
}

SYSV void SDL_Log_sysv(const char *fmt, const char *arg1, const char *arg2)
{
    SDL_Log(fmt, arg1, arg2);
}

SYSV MIX_Audio *MIX_LoadAudio_sysv(MIX_Mixer *mixer, const char *path, bool predecode)
{
    return MIX_LoadAudio(mixer, path, predecode);
}

SYSV MIX_Mixer *MIX_CreateMixerDevice_sysv(SDL_AudioDeviceID devid, const SDL_AudioSpec *spec)
{
    return MIX_CreateMixerDevice(devid, spec);
}

SYSV MIX_Track *MIX_CreateTrack_sysv(MIX_Mixer *mixer)
{
    return MIX_CreateTrack(mixer);
}

SYSV bool MIX_SetTrackAudio_sysv(MIX_Track *track, MIX_Audio *audio)
{
    return MIX_SetTrackAudio(track, audio);
}

SYSV bool MIX_PlayTrack_sysv(MIX_Track *track, SDL_PropertiesID options)
{
    return MIX_PlayTrack(track, options);
}

SYSV void MIX_Quit_sysv(void)
{
    MIX_Quit();
}

SYSV bool MIX_Init_sysv(void){
    return MIX_Init();
}

SYSV bool TTF_Init_sysv(void)
{
    return TTF_Init();
}

SYSV TTF_Font* TTF_OpenFont_sysv(const char *fontname, float ptsize)
{
    return TTF_OpenFont(fontname, ptsize);
}

SYSV SDL_Surface* TTF_RenderText_Blended_sysv(TTF_Font *font, const char *text, size_t length, SDL_Color color)
{
    return TTF_RenderText_Blended(font, text, length, color);
}

SYSV SDL_Texture* SDL_CreateTextureFromSurface_sysv(SDL_Renderer *renderer, SDL_Surface *surface)
{
    return SDL_CreateTextureFromSurface(renderer, surface);
}

SYSV void SDL_DestroySurface_sysv(SDL_Surface *surface)
{
    SDL_DestroySurface(surface);
}

SYSV int SDL_RenderTexture_sysv(SDL_Renderer * renderer, SDL_Texture * texture, const SDL_FRect * srcrect, const SDL_FRect * dstrect)
{
    return SDL_RenderTexture( renderer, texture, srcrect, dstrect );
}

SYSV void TTF_CloseFont_sysv(TTF_Font *font)
{
    TTF_CloseFont(font);
}

SYSV void TTF_Quit_sysv(void)
{
    TTF_Quit();
}