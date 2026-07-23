from concurrent.futures import ThreadPoolExecutor

class ThreadManager:
    _instance = None

    def __init__(self):
        self.executor = ThreadPoolExecutor(max_workers=4, thread_name_prefix="TinQaWorker")

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = ThreadManager()
        return cls._instance

    def submit(self, fn, *args, **kwargs):
        return self.executor.submit(fn, *args, **kwargs)