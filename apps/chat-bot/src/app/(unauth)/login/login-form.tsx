'use client';

import SharedChatLoginForm from '../../(authed)/(chat-bot)/learning-scenarios/_components/shared-chat-login-form';
import { signIn } from 'next-auth/react';
import LogoWithName from '@/assets/logo-with-name.svg';
import Image from 'next/image';
import { useSearchParams } from 'next/navigation';
import { getSafeCallbackUrl } from '@/auth/callback-url';
import { Button } from '@ui/components/button';

export default function LoginForm() {
  const searchParams = useSearchParams();
  const callbackUrl = getSafeCallbackUrl(searchParams.get('callbackUrl'));

  return (
    <main className="w-full flex flex-col justify-center items-center max-w-72 mx-auto py-4 h-full">
      <div className="my-auto flex flex-col items-center w-full">
        <div className="flex items-center gap-4 my-8 sm:my-16">
          <Image
            src="https://edpsych-ai.de/cdn/images/LMU_Logo_RGB_FlaechigGruen.png"
            alt="LMU München"
            width={120}
            height={40}
            unoptimized
          />
          <Image
            src="https://edpsych-ai.de/cdn/images/DigiLLab-Logo.png"
            alt="DigiLLab"
            width={120}
            height={40}
            unoptimized
          />
        </div>
        <LogoWithName className="text-primary mb-8 sm:mb-16 h-13" />
        <SharedChatLoginForm />
        <div className="flex gap-2 items-center w-full justify-center py-8">
          <hr className="grow border-t border-gray-200" />
          <span className="text-sm text-gray-200">oder</span>
          <hr className="grow border-t border-gray-200" />
        </div>
        <Button
          variant="outline"
          size="xl"
          className="w-full"
          onClick={() => signIn('vidis', { callbackUrl })}
          aria-label="Mit VIDIS einloggen"
          data-testid="vidis-login-button"
        >
          Mit VIDIS einloggen
        </Button>
      </div>
    </main>
  );
}
