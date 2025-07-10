import { Controller, Post, Body, HttpException, HttpStatus } from '@nestjs/common';
import { AuthGoogleService, GoogleAuthDto } from './auth-google.service';

@Controller('auth')
export class AuthGoogleController {
  constructor(private readonly authGoogleService: AuthGoogleService) {}

  @Post('google')
  async signInWithGoogle(@Body() googleAuthDto: GoogleAuthDto) {
    try {
      const result = await this.authGoogleService.signInWithGoogle(googleAuthDto);
      return result;
    } catch (error) {
      throw new HttpException(
        {
          status: HttpStatus.UNAUTHORIZED,
          error: error.message || 'Erreur lors de l\'authentification Google',
        },
        HttpStatus.UNAUTHORIZED,
      );
    }
  }
}
