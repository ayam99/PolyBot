from telegram.ext import Updater, MessageHandler, Filters

from utils import search_download_youtube_video
from loguru import logger
import os


class Bot:

    def __init__(self, token):
        # create frontend object to the bot programmer
        self.updater = Updater(token, use_context=True)

        # add _message_handler as main internal msg handler
        self.updater.dispatcher.add_handler(MessageHandler(Filters.text, self._message_handler))

    def start(self):
        """Start polling msgs from users, this function never returns"""
        self.updater.start_polling()
        logger.info(f'{self.__class__.__name__} is up and listening to new messages....')
        self.updater.idle()

    def _message_handler(self, update, context):
        """Main messages handler"""
        self.send_text(update, f'Your original message: {update.message.text}')

    # Changing in send_video function because of the (Optional) in Part 5

    def send_video(self, update, context, video_id):
        """Sends video to a chat"""
        if video_id in self.video_cache:
            file_path = self.video_cache[video_id]
            self.send_text(update, f'Sending cached copy of video {video_id}...')
        else:
            file_path = search_download_youtube_video(video_id)
            self.video_cache[video_id] = file_path
        context.bot.send_video(chat_id=update.message.chat_id, video=open(file_path, 'rb'), supports_streaming=True)

    def send_text(self, update, text, quote=False):
        """Sends text to a chat"""
        # retry https://github.com/python-telegram-bot/python-telegram-bot/issues/1124
        update.message.reply_text(text, quote=quote)


class QuoteBot(Bot):
    def _message_handler(self, update, context):
        to_quote = True

        if update.message.text == 'Don\'t quote me please':
            to_quote = False

        self.send_text(update, f'Your original message: {update.message.text}', quote=to_quote)


class YoutubeBot(Bot):

    # Continue to Part 5 (Optional)
    def __init__(self, token):
        super().__init__(token)
        self.cache_dir = 'video_cache'
        if not os.path.exists(self.cache_dir):
            os.mkdir(self.cache_dir)
        self.video_cache = {}

    # YouTube downloading
    def _message_handler(self, update, context):
        """Handles messages containing video IDs"""
        text = update.message.text
        if text.startswith('https://www.youtube.com/watch?v='):
            video_id = text.split('=')[-1]
            self.send_video(update, context, video_id)
        else:
            self.send_text(update, 'Invalid video link')


if __name__ == '__main__':
    with open('.telegramToken') as f:
        _token = f.read()

    youtubebot = YoutubeBot(_token)
    youtubebot.start()
